//
//  Film.swift
//  starwars
//
//

import Foundation

struct Film: Codable {
    var title: String
    var director: String
    var producer: String
    var openingCrawl: String
    var characters: [String]
}
