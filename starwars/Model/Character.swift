//
//  Character.swift
//  starwars
//
//

import Foundation

/// A StarWars Character.
struct MovieCharacter: Codable {
    var name: String
    var homeworld: String
    var hairColor: String
    var height: String
    var homeworldName: String?
}
