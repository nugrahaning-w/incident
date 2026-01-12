//
//  DateExtension.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation

extension Date {

    var incidentFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        return formatter.string(from: self)
    }
}
