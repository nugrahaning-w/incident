//
//  IncidentListViewModel.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class IncidentListViewModel: BaseViewModel {

    // Inputs
    let reloadTrigger = PublishRelay<Void>()
    let sortAscending = BehaviorRelay<Bool>(value: false)
    let searchQuery = BehaviorRelay<String>(value: "")

    // Outputs
    lazy var incidents: Observable<[Incident]> = {
        let fetched = reloadTrigger
            .startWith(())
            .do(onNext: { [weak self] _ in self?.activityRelay.accept(true) }) // start loading
            .flatMapLatest { [repository, errorRelay] _ in
                repository.fetchIncidents()
                    .asObservable()
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .do(onNext: { [weak self] _ in self?.activityRelay.accept(false) },
                onError: { [weak self] _ in self?.activityRelay.accept(false) },
                onCompleted: { [weak self] in self?.activityRelay.accept(false) })
            .share(replay: 1, scope: .whileConnected) // <-- scoped replay

        return Observable
            .combineLatest(fetched, sortAscending)
            .map { list, ascending in
                list.sorted {
                    ascending ? $0.lastUpdated < $1.lastUpdated
                              : $0.lastUpdated > $1.lastUpdated
                }
            }
            .share(replay: 1, scope: .whileConnected) // <-- scoped replay
    }()

    lazy var filteredIncidents: Observable<[Incident]> = {
        Observable
            .combineLatest(incidents, searchQuery.distinctUntilChanged())
            .map(Self.filterIncidents)
            .share(replay: 1, scope: .whileConnected) // <-- scoped replay
    }()

    lazy var incidentsDriver: Driver<[Incident]> = {
        incidents.observe(on: MainScheduler.instance).asDriver(onErrorJustReturn: [])
    }()

    lazy var filteredIncidentsDriver: Driver<[Incident]> = {
        filteredIncidents.observe(on: MainScheduler.instance).asDriver(onErrorJustReturn: [])
    }()

    lazy var isLoadingDriver: Driver<Bool> = {
        isLoading.observe(on: MainScheduler.instance).asDriver(onErrorJustReturn: false)
    }()

    // Loading state
    private let activityRelay = BehaviorRelay<Bool>(value: false)
    var isLoading: Observable<Bool> { activityRelay.asObservable().distinctUntilChanged() }

    // Dependencies
    private let repository: IncidentRepository

    init(repository: IncidentRepository) {
        self.repository = repository
        super.init()
    }

    // Pure function (SRP)
    private static func filterIncidents(list: [Incident], query: String) -> [Incident] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return list }
        return list.filter { inc in
            let statusText = inc.status.rawValue.lowercased()
            return inc.title.lowercased().contains(q)
                || inc.location.lowercased().contains(q)
                || inc.type.lowercased().contains(q)
                || statusText.contains(q)
        }
    }
}
