import Foundation
import RxSwift

protocol IncidentRepository {
    func fetchIncidents() -> Single<[Incident]>
}