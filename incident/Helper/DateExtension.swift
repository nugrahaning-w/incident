//
//  DateExtension.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation

private enum IncidentDateFormatter {
    static let display: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        return f
    }()
}

extension Date {
    var incidentFormatted: String {
        IncidentDateFormatter.display.string(from: self)
    }
}
