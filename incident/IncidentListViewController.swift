//
//  IncidentListViewController.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import UIKit
import RxSwift
import RxCocoa

class IncidentListViewController: UIViewController {

    // MARK: - UI

        private let tableView = UITableView()
        private let refreshControl = UIRefreshControl()

        // MARK: - Properties

        private let viewModel: IncidentListViewModel
        private let disposeBag = DisposeBag()

        // MARK: - Init

        init(viewModel: IncidentListViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTableView()
            setupNavigationBar()
            bindViewModel()
        }

        // MARK: - Setup UI

        private func setupUI() {
            view.backgroundColor = .systemGroupedBackground
            title = "Incidents"

            view.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        private func setupTableView() {
            tableView.register(IncidentTableViewCell.self,
                               forCellReuseIdentifier: IncidentTableViewCell.identifier)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 80
            tableView.refreshControl = refreshControl
            tableView.tableFooterView = UIView()
        }

        private func setupNavigationBar() {
            let sortButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.up.arrow.down"),
                style: .plain,
                target: nil,
                action: nil
            )
            navigationItem.rightBarButtonItem = sortButton

            sortButton.rx.tap
                .withLatestFrom(viewModel.sortAscending)
                .map { !$0 }
                .bind(to: viewModel.sortAscending)
                .disposed(by: disposeBag)
        }

        // MARK: - Bindings

        private func bindViewModel() {

            // Reload trigger (initial + pull to refresh)
            Observable.merge(
                Observable.just(()),
                refreshControl.rx.controlEvent(.valueChanged).map { _ in }
            )
            .bind(to: viewModel.reloadTrigger)
            .disposed(by: disposeBag)

            // Bind incidents to tableView
            viewModel.incidents
                .observe(on: MainScheduler.instance)
                .do(onNext: { [weak self] _ in
                    self?.refreshControl.endRefreshing()
                })
                .bind(to: tableView.rx.items(
                    cellIdentifier: IncidentTableViewCell.identifier,
                    cellType: IncidentTableViewCell.self
                )) { _, incident, cell in
                    cell.configure(with: incident)
                }
                .disposed(by: disposeBag)

            // Handle cell selection
            tableView.rx.modelSelected(Incident.self)
                .subscribe(onNext: { [weak self] incident in
                    self?.showDetail(incident)
                })
                .disposed(by: disposeBag)

            // Deselect cell automatically
            tableView.rx.itemSelected
                .subscribe(onNext: { [weak self] indexPath in
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                })
                .disposed(by: disposeBag)

            // Bind error messages to show an alert
            viewModel.errorMessage
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] message in
                    self?.showErrorAlert(message: message)
                })
                .disposed(by: disposeBag)
        }

        // MARK: - Navigation

        private func showDetail(_ incident: Incident) {
            print("Go to detail")
    //        let viewModel = IncidentDetailViewModel(incident: incident)
    //        let vc = IncidentDetailViewController(viewModel: viewModel)
    //        navigationController?.pushViewController(vc, animated: true)
        }

        // MARK: - Error Handling

        private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
