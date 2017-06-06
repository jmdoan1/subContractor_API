import Vapor
import VaporMySQL
import Fluent
import Auth
import HTTP
import Cookies
import Turnstile
import TurnstileCrypto
import TurnstileWeb

//API resources
//https://codeplanet.io/principles-good-restful-api-design/
//https://blog.mwaysolutions.com/2014/06/05/10-best-practices-for-better-restful-api/

//Vapor resources
//https://medium.com/@xGoPox/relation-with-vapor-server-side-swift-b0a5f2daed4f

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

drop.post("openings", Int.self) { request, owner_id in
    guard let contractor = try Contractor.query().filter("id", Node(owner_id)).first(),
        let title = request.data["title"]?.string,
        let description = request.data["description"]?.string,
        let type = request.data["type"]?.string,
        let scope = request.data["scope"]?.string,
        let structure = request.data["structure"]?.string,
        let rate = request.data["rate"]?.double,
        let showRate = request.data["showRate"]?.bool,
        let open = request.data["open"]?.bool else {
            throw Abort.custom(status: .badRequest, message: "Missing data")
    }
    
    var opening = Opening(title: title, description: description, type: type, scope: scope, structure: structure, rate: rate, showRate: showRate, open: open)
    opening.contractor_id = contractor.id
    try opening.save()
    return opening
}

drop.get("openings") { request in
    return try Opening.all().makeJSON()
}

drop.get("openings", Int.self) { request, owner_id in
    guard let contractor = try Contractor.query().filter("id", Node(owner_id)).first() else {
            throw Abort.custom(status: .badRequest, message: "Missing data")
    }
    
    return try contractor.openings().all().makeJSON()
}

drop.run()
