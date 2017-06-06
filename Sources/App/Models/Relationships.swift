//
//  Relationships.swift
//  SubContract_API
//
//  Created by Justin Doan on 6/4/17.
//
//

import Foundation
import Vapor
import Fluent

extension Entry {
    func owner() throws -> Parent<Contractor> {
        return try parent(ownerId)
    }
}

extension Contractor {
    func entries() throws -> Children<Entry> {
        return try children()
    }
}

extension Opening {
    func owner() throws -> Parent<Contractor> {
        return try parent(contractor_id)
    }
}

extension Contractor {
    func openings() throws -> Children<Opening> {
        return try children()
    }
}
