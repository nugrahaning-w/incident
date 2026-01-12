//
//  Incident.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation
import UIKit

struct Incident: Decodable {
    let id: String
    let title: String
    let type: String
    let status: IncidentStatus
    let location: String
    let latitude: Double
    let longitude: Double
    let callTime: Date
    let lastUpdated: Date
    let description: String
    let iconURL: URL

    private enum CodingKeys: String, CodingKey {
        case id, title, type, status, location, latitude, longitude, callTime, lastUpdated, description
        case typeIcon // maps to iconURL
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        type = try c.decode(String.self, forKey: .type)

        // Normalisasi status ke enum
        let rawStatus = try c.decode(String.self, forKey: .status)
        status = IncidentStatus(fromRawOrLoose: rawStatus)

        location = try c.decode(String.self, forKey: .location)
        latitude = try c.decode(Double.self, forKey: .latitude)
        longitude = try c.decode(Double.self, forKey: .longitude)

        // Format "2022-07-06T12:44:10+1000"
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let callTimeStr = try c.decode(String.self, forKey: .callTime)
        guard let call = df.date(from: callTimeStr) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.callTime],
                                                    debugDescription: "Invalid date: \(callTimeStr)"))
        }
        callTime = call

        let lastUpdatedStr = try c.decode(String.self, forKey: .lastUpdated)
        guard let updated = df.date(from: lastUpdatedStr) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.lastUpdated],
                                                    debugDescription: "Invalid date: \(lastUpdatedStr)"))
        }
        lastUpdated = updated

        // description bisa null → fallback ke title
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? title

        // typeIcon → iconURL
        let iconStr = try c.decode(String.self, forKey: .typeIcon)
        guard let url = URL(string: iconStr) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.typeIcon],
                                                    debugDescription: "Invalid URL: \(iconStr)"))
        }
        iconURL = url
    }
}
