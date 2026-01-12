//
//  IncidentStatus.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import UIKit

enum IncidentStatus: String, Decodable {
    case underControl = "Under Control"
    case onScene = "On Scene"
    case outOfControl = "Out of Control"
    case pending = "Pending"

    var color: UIColor {
        switch self {
        case .underControl: return .systemGreen
        case .onScene: return .systemBlue
        case .outOfControl: return .systemRed
        case .pending: return .systemOrange
        }
    }
}

extension IncidentStatus {
    init(fromRawOrLoose raw: String) {
        switch raw.lowercased() {
        case "under control": self = .underControl
        case "on scene": self = .onScene
        case "out of control": self = .outOfControl
        case "pending": self = .pending
        default: self = .pending
        }
    }
}
