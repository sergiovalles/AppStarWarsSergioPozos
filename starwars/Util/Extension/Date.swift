//
//  Date.swift
//  starwars
//
//

import Foundation

extension Date {
    func convertToFormat() -> String {
        return formatted(.dateTime.day(.twoDigits).month(.twoDigits).year())
    }
}
