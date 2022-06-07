//
//  User.swift
//  starwars
//
//

import Foundation

struct UserSearchResponse: Codable {
    var results: [User?]
}

struct User: Codable {
    var name: String
    var hairColor: String
    var created: String
    var films: [String]
}
