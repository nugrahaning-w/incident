//
//  IncidentDetailViewController.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 12/01/26.
//
import UIKit
import MapKit
import SnapKit

final class IncidentDetailViewController: UIViewController, MKMapViewDelegate {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let mapContainer = UIView()
    private let mapView = MKMapView()

    private let cardView = UIView()
    private let infoStack = UIStackView()

    // MARK: - Properties
    private let viewModel: IncidentDetailViewModel

    // MARK: - Init
    init(viewModel: IncidentDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        configure()
        centerMapAndAddAnnotation()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = viewModel.titleText

        // Scroll
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)

        // Map container
        mapContainer.backgroundColor = .secondarySystemBackground
        mapContainer.layer.cornerRadius = 12
        mapContainer.layer.masksToBounds = true

        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true

        // Card
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true

        infoStack.axis = .vertical
        infoStack.spacing = 0

        // Build view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(mapContainer)
        mapContainer.addSubview(mapView)
        contentStack.addArrangedSubview(cardView)
        cardView.addSubview(infoStack)
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        mapContainer.snp.makeConstraints { make in
            make.height.equalTo(220)
        }
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        infoStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    private func configure() {
        // Build rows in the info card
        addInfoRow(title: "Location", value: viewModel.locationText)
        addSeparator()
        addInfoRow(title: "Status", value: viewModel.statusText)
        addSeparator()
        addInfoRow(title: "Type", value: viewModel.typeText)
        addSeparator()
        addInfoRow(title: "Call Time", value: viewModel.callTimeText)
        addSeparator()
        addInfoRow(title: "Description", value: viewModel.descriptionText, multiline: true)
    }

    private func addInfoRow(title: String, value: String, multiline: Bool = false) {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title.uppercased()

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.text = value
        valueLabel.numberOfLines = multiline ? 0 : 1

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }

        infoStack.addArrangedSubview(container)
    }

    private func addSeparator() {
        let sep = UIView()
        sep.backgroundColor = .separator
        sep.snp.makeConstraints { make in
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        infoStack.addArrangedSubview(sep)
    }

    // MARK: - Map
    private func centerMapAndAddAnnotation() {
        let coord = viewModel.coordinate
        let region = MKCoordinateRegion(center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapView.setRegion(region, animated: false)

        let annotation = MKPointAnnotation()
        annotation.title = viewModel.typeText
        annotation.subtitle = viewModel.statusText
        annotation.coordinate = coord
        mapView.addAnnotation(annotation)
    }

    // Pin with custom icon
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let id = "IncidentPin"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: id)
        view.annotation = annotation
        view.canShowCallout = true

        // Default image while loading
        view.image = UIImage(systemName: "mappin.circle.fill")

        if let url = URL(string: viewModel.iconURLString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    view.image = img
                    view.frame.size = CGSize(width: 36, height: 36)
                }
            }.resume()
        } else {
            view.frame.size = CGSize(width: 36, height: 36)
        }
        return view
    }
}