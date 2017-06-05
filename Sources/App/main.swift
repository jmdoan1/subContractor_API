import Vapor
import VaporMySQL
import Fluent
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb

let drop = Droplet()
let auth = AuthMiddleware<Contractor>()

drop.preparations = [Contractor.self, Entry.self, Opening.self]
try drop.addProvider(VaporMySQL.Provider.self)

drop.middleware.append(auth)
drop.middleware.append(TrustProxyMiddleware())

drop.post("register") { request in
    guard let username = request.formURLEncoded?["username"]?.string,
        let password = request.formURLEncoded?["password"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Missing username or password")
    }
    let credentials = UsernamePassword(username: username, password: password)
    
    do {
        try _ = Contractor.register(credentials: credentials)
        try request.auth.login(credentials)
        return try JSON(node: request.auth.user())
    } catch let e as TurnstileError {
        throw Abort.custom(status: .badRequest, message: "\(e)")
    }
}

drop.post("login") { request in
    guard let username = request.formURLEncoded?["username"]?.string,
        let password = request.formURLEncoded?["password"]?.string else {
            throw Abort.custom(status: .badRequest, message: "Missing username or password")
    }
    let credentials = UsernamePassword(username: username, password: password)
    do {
        try request.auth.login(credentials)
        return try JSON(node: request.auth.user())
    } catch let e {
        throw Abort.custom(status: .badRequest, message: "\(e)")
    }
}



drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.post("entries") { req in
    guard let username = req.data["username"]?.string else {
        throw Abort.custom(status: .badRequest, message: "failed to send username")
    }
    
    guard let content = req.data["content"]?.string else {
        throw Abort.custom(status: .badRequest, message: "Please enter a message")
    }
    
    var newEntry = Entry(username: username, content: content)
    
    try newEntry.save()
    
    return newEntry
}

drop.get("entries") { req in
    
    let entries = try Entry.all()
    
    return try JSON(node: entries)
}


drop.run()
