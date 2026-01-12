//
//  IncidentDetailViewModel.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 12/01/26.
//
import Foundation
import CoreLocation

final class IncidentDetailViewModel: BaseViewModel {

    // MARK: - Stored
    private let incident: Incident
    private let formatter: DateFormatting

    // MARK: - Outputs for UI
    var titleText: String { incident.title }
    var locationText: String { incident.location }
    var statusText: String { incident.status.rawValue }
    var typeText: String { incident.type }
    var callTimeText: String { formatter.displayString(for: incident.callTime) }
    var descriptionText: String { incident.description }
    var coordinate: CLLocationCoordinate2D { .init(latitude: incident.latitude, longitude: incident.longitude) }
    var iconURLString: String { incident.iconURL.absoluteString }

    // MARK: - Init
    init(incident: Incident, formatter: DateFormatting = IncidentDateFormatterProvider()) {
        self.incident = incident
        self.formatter = formatter
        super.init()
    }
}
