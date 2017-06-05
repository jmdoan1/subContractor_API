//
//  Opening.swift
//  SubContract_API
//
//  Created by Justin Doan on 6/4/17.
//
//

import Vapor
import VaporMySQL
import Fluent
import Foundation

final class Opening: Model {
    var id: Node?
    var ownerId: Node?
    var time: Int
    var title: String
    var description: String
    var type: String //.emplyment, .contract, .subContract
    var scope: String // .hours, .weeks, .months, .years
    var structure: String // .hourly, .fixed
    var rate: Double
    var showRate: Bool
    var open: Bool
    var exists: Bool = false
    
    init(time: Int, title: String, description: String, type: String, scope: String, structure: String, rate: Double, showRate: Bool, open: Bool) {
        self.time = time
        self.title = title
        self.description = description
        self.type = type
        self.scope = scope
        self.structure = structure
        self.rate = rate
        self.showRate = showRate
        self.open = open
    }
    
    convenience init(title: String, description: String, type: String, scope: String, structure: String, rate: Double, showRate: Bool, open: Bool) {
        
        self.init(time: Int(Date().timeIntervalSince1970), title: title, description: description, type: type, scope: scope, structure: structure, rate: rate, showRate: showRate, open: open)
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        ownerId = try node.extract("ownerId")
        time = try node.extract("time")
        title = try node.extract("title")
        description = try node.extract("description")
        type = try node.extract("type")
        scope = try node.extract("scope")
        structure = try node.extract("structure")
        rate = try node.extract("rate")
        showRate = try node.extract("showRate")
        open = try node.extract("open")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "ownerId": ownerId,
            "time": time,
            "title": title,
            "description": description,
            "type": type,
            "scope": scope,
            "structure": structure,
            "rate": rate,
            "showRate": showRate,
            "open": open
            ])
    }
    
    func makeJSON() throws -> JSON {
        let node = try makeNode()
        return try JSON(node: node)
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("openings") { opening in
            opening.id()
            opening.parent(Contractor.self, optional: false)
            opening.int("time")
            opening.string("title")
            opening.string("description")
            opening.string("type")
            opening.string("scope")
            opening.string("structure")
            opening.double("rate")
            opening.bool("showRate")
            opening.bool("open")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("entrys")
    }
}
