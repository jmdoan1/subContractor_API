//
//  Entry.swift
//  SubContract_API
//
//  Created by Justin Doan on 6/4/17.
//
//

import Vapor
import VaporMySQL
import Fluent
import Foundation

final class Entry: Model {
    var id: Node?
    var ownerId: Node?
    var username: String
    var content: String
    var time: Int
    var exists: Bool = false
    
    init(username: String, content: String, time: Int) {
        self.username = username
        self.content = content
        self.time = time
    }
    
    convenience init(username: String, content: String) {
        let date = Date()
        self.init(username: username, content: content, time: Int(date.timeIntervalSince1970))
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        ownerId = try node.extract("ownerId")
        username = try node.extract("username")
        content = try node.extract("content")
        time = try node.extract("time")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "ownerId": ownerId,
            "username": username,
            "content": content,
            "time": time
            ])
    }
    
    func makeJSON() throws -> JSON {
        let node = try makeNode()
        return try JSON(node: node)
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("entrys") { entry in
            entry.id()
            entry.parent(Contractor.self, optional: false)
            entry.string("username")
            entry.string("content")
            entry.int("time")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("entrys")
    }
}
