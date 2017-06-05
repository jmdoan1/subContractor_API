//
//  Request+VaporAuth.swift
//  SubContract_API
//
//  Created by Justin Doan on 5/17/17.
//
//

import Foundation
import Turnstile
import HTTP

extension Request {
    // Base URL returns the hostname, scheme, and port in a URL string form.
    var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
    // Exposes the Turnstile subject, as Vapor has a facade on it.
    var subject: Subject {
        return storage["subject"] as! Subject
    }
}
