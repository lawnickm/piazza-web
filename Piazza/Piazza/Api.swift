//
//  Api.swift
//  Piazza
//
//  Created by Jared Rader on 12/29/22.
//

import Foundation

struct Api {
    #if DEBUG
        static let rootURL = URL(string: "http://localhost:3000/")!
    #else
        static let rootURL = URL(string: "https://piazza-web-mi2v.onrender.com/")!
    #endif
    
    struct Path {
        static let login = Api.rootURL.appendingPathComponent("login")
        static let profile = Api.rootURL.appendingPathComponent("profile")
    }
}
