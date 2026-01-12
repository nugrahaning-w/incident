//
//  DateExtension.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation

protocol DateFormatting {
    func displayString(for date: Date) -> String
}

struct IncidentDateFormatterProvider: DateFormatting {
    private static let display: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        return f
    }()
    func displayString(for date: Date) -> String {
        Self.display.string(from: date)
    }
}
