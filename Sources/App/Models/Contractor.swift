//
//  Contractor.swift
//  SubContract_API
//
//  Created by Justin Doan on 5/17/17.
//
//

import Foundation
import HTTP
import Fluent
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import Auth

final class Contractor: User {
    // Field for the Fluent ORM
    var exists: Bool = false
    
    // Database Fields
    var id: Node?
    var username: String
    var password = ""
    var facebookID = ""
    var googleID = ""
    var apiKeyID = URandom().secureToken
    var apiKeySecret = URandom().secureToken
    var dateCreated = Int(Date().timeIntervalSince1970)
    var nameFirst = ""
    var nameLast = ""
    var website = ""
    var linkedIn = ""
    var available = false
    
    
    /**
     Authenticates a set of credentials against the User.
     */
    static func authenticate(credentials: Credentials) throws -> User {
        var user: Contractor?
        
        switch credentials {
            /**
             Fetches a user, and checks that the password is present, and matches.
             */
        case let credentials as UsernamePassword:
            let fetchedUser = try Contractor.query()
                .filter("username", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
            /**
             Fetches the user by session ID. Used by the Vapor session manager.
             */
        case let credentials as Identifier:
            user = try Contractor.find(credentials.id)
            
            /**
             Fetches the user by Facebook ID. If the user doesn't exist, autoregisters it.
             */
        case let credentials as FacebookAccount:
            if let existing = try Contractor.query().filter("facebook_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try Contractor.register(credentials: credentials) as? Contractor
            }
            
            /**
             Fetches the user by Google ID. If the user doesn't exist, autoregisters it.
             */
        case let credentials as GoogleAccount:
            if let existing = try Contractor.query().filter("google_id", credentials.uniqueID).first() {
                user = existing
            } else {
                user = try Contractor.register(credentials: credentials) as? Contractor
            }
            
            /**
             Authenticates via API Keys
             */
        case let credentials as APIKey:
            user = try Contractor.query()
                .filter("api_key_id", credentials.id)
                .filter("api_key_secret", credentials.secret)
                .first()
            
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    /**
     Registers users for UsernamePassword, Facebook, or Google accounts.
     */
    static func register(credentials: Credentials) throws -> User {
        var newUser: Contractor
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = Contractor(credentials: credentials)
        case let credentials as FacebookAccount:
            newUser = Contractor(credentials: credentials)
        case let credentials as GoogleAccount:
            newUser = Contractor(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if try Contractor.query().filter("username", newUser.username).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
        
    }
    
    init(credentials: UsernamePassword) {
        self.username = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
    }
    
    init(credentials: FacebookAccount) {
        self.username = "fb" + credentials.uniqueID
        self.facebookID = credentials.uniqueID
    }
    
    init(credentials: GoogleAccount) {
        self.username = "goog" + credentials.uniqueID
        self.googleID = credentials.uniqueID
    }
    
    /**
     Initializer for Fluent
     */
    init(node: Node, in context: Context) throws {
        id = node["id"]
        username = try node.extract("username")
        password = try node.extract("password")
        facebookID = try node.extract("facebook_id")
        googleID = try node.extract("google_id")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
        dateCreated = Int(Date().timeIntervalSince1970)
        nameFirst = try node.extract("nameFirst")
        nameLast = try node.extract("nameLast")
        website = try node.extract("website")
        linkedIn = try node.extract("linkedIn")
        available = false
    }
    
    /**
     Serializer for Fluent
     */
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "password": password,
            "facebook_id": facebookID,
            "google_id": googleID,
            "api_key_id": apiKeyID,
            "api_key_secret": apiKeySecret,
            "dateCreated": dateCreated,
            "nameFirst": nameFirst,
            "nameLast": nameLast,
            "website": website,
            "linkedIn": linkedIn,
            "available": available
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("contractors") { user in
            user.id()
            user.string("username")
            user.string("password")
            user.string("facebook_id")
            user.string("google_id")
            user.string("api_key_id")
            user.string("api_key_secret")
            user.int("dateCreated")
            user.string("nameFirst")
            user.string("nameLast")
            user.string("website")
            user.string("linkedIn")
            user.bool("available")
        }
    }


    static func revert(_ database: Database) throws {}
}

extension Request {
    func user() throws -> Contractor {
        guard let user = try auth.user() as? Contractor else {
            throw "Invalid user type"
        }
        return user
    }
}

extension String: Error {}
