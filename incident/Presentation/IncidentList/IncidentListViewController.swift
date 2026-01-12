//
//  IncidentListViewController.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import UIKit
import RxSwift
import RxCocoa

final class IncidentListViewController: BaseViewController<IncidentListViewModel> {

    // UI
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No results"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()

    override var showsLargeTitle: Bool { true }

    // Init uses BaseViewController’s generic init
    override func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Incidents"

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Top-centered small spinner for initial load
        loadingIndicator.hidesWhenStopped = true
        navigationItem.titleView = loadingIndicator

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(IncidentTableViewCell.self,
                           forCellReuseIdentifier: IncidentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()

        // Navigation buttons
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: nil, action: nil)
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = sortButton
        navigationItem.leftBarButtonItem = searchButton

        // Search controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search incidents"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Button actions
        searchButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.searchController.isActive = true
                DispatchQueue.main.async { self.searchController.searchBar.becomeFirstResponder() }
            })
            .disposed(by: disposeBag)

        sortButton.rx.tap
            .withLatestFrom(viewModel.sortAscending)
            .map { !$0 }
            .bind(to: viewModel.sortAscending)
            .disposed(by: disposeBag)

        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func setupBindings() {
        super.setupBindings()

        // Bind search text
        searchController.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)

        // Reload trigger (initial + pull-to-refresh)
        Observable.merge(
            Observable.just(()),
            refreshControl.rx.controlEvent(.valueChanged).map { _ in }
        )
        .bind(to: viewModel.reloadTrigger)
        .disposed(by: disposeBag)

        // Loading state → spinner and refresh control
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self else { return }
                if loading {
                    // show top spinner if not pulling
                    if self.refreshControl.isRefreshing == false {
                        self.loadingIndicator.startAnimating()
                    }
                } else {
                    self.loadingIndicator.stopAnimating()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                }
            })
            .disposed(by: disposeBag)

        // Table binding
        viewModel.filteredIncidents
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: IncidentTableViewCell.identifier,
                cellType: IncidentTableViewCell.self
            )) { _, incident, cell in
                cell.configure(with: incident)
            }
            .disposed(by: disposeBag)

        // Selection
        tableView.rx.modelSelected(Incident.self)
            .subscribe(onNext: { [weak self] incident in
                self?.showDetail(incident)
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(viewModel.filteredIncidents, viewModel.isLoading)
            .map { items, loading in items.isEmpty && !loading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] show in
                self?.emptyLabel.isHidden = !show
            })
            .disposed(by: disposeBag)
    }

    private func showDetail(_ incident: Incident) {
        let vm = IncidentDetailViewModel(incident: incident)
        let vc = IncidentDetailViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}
