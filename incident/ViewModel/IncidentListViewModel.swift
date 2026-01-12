//
//  IncidentListViewModel.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation
import RxSwift
import RxRelay

final class IncidentListViewModel {

    // Inputs
    let reloadTrigger = PublishRelay<Void>()
    let sortAscending = BehaviorRelay<Bool>(value: false)

    // Outputs
    let incidents: Observable<[Incident]>
    let errorMessage: Observable<String>

    private let service: IncidentServiceProtocol
    private let errorRelay = PublishRelay<String>()

    init(service: IncidentServiceProtocol) {
        self.service = service
        self.errorMessage = errorRelay.asObservable()

        let fetched = reloadTrigger
            .startWith(())
            .flatMapLatest { [service, errorRelay] _ in
                service.fetchIncidentsRx()
                    .asObservable()
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .share(replay: 1)

        incidents = Observable
            .combineLatest(fetched, sortAscending)
            .map { list, ascending in
                list.sorted {
                    ascending ? $0.lastUpdated < $1.lastUpdated
                              : $0.lastUpdated > $1.lastUpdated
                }
            }
    }
}
