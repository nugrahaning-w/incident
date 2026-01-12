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

    // MARK: - Outputs for UI
    var titleText: String { incident.title }
    var locationText: String { incident.location }
    var statusText: String {
        switch incident.status {
        case .underControl: return "Under Control"
        case .onScene: return "On Scene"
        case .outOfControl: return "Out of Control"
        case .pending: return "Pending"
        }
    }
    var typeText: String { incident.type }
    var callTimeText: String { incident.callTime.incidentFormatted }
    var descriptionText: String { incident.description }
    var coordinate: CLLocationCoordinate2D { .init(latitude: incident.latitude, longitude: incident.longitude) }
    var iconURLString: String { incident.iconURL.absoluteString }

    // MARK: - Init
    init(incident: Incident) {
        self.incident = incident
        super.init()
    }
}
