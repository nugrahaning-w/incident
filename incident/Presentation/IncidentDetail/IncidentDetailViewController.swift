//
//  IncidentDetailViewController.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 12/01/26.
//
import UIKit
import MapKit
import SnapKit

final class IncidentDetailViewController: BaseViewController<IncidentDetailViewModel>, MKMapViewDelegate {

    private let imageLoader: ImageLoading = ImageLoader.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let mapContainer = UIView()
    private let mapView = MKMapView()
    private let cardView = UIView()
    private let infoStack = UIStackView()

    override func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = viewModel.titleText

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)

        mapContainer.backgroundColor = .secondarySystemBackground
        mapContainer.layer.cornerRadius = 12
        mapContainer.layer.masksToBounds = true

        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "IncidentPin")

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true

        infoStack.axis = .vertical
        infoStack.spacing = 0

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(mapContainer)
        mapContainer.addSubview(mapView)
        contentStack.addArrangedSubview(cardView)
        cardView.addSubview(infoStack)

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

        // Info rows
        addInfoRow(title: "Location", value: viewModel.locationText)
        addSeparator()
        addInfoRow(title: "Status", value: viewModel.statusText)
        addSeparator()
        addInfoRow(title: "Type", value: viewModel.typeText)
        addSeparator()
        addInfoRow(title: "Call Time", value: viewModel.callTimeText)
        addSeparator()
        addInfoRow(title: "Description", value: viewModel.descriptionText, multiline: true)

        // Map annotation
        centerMapAndAddAnnotation()
    }

    override func setupBindings() {
        super.setupBindings()
        // No additional reactive bindings for now
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let id = "IncidentPin"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation)
        view.annotation = annotation
        view.canShowCallout = true

        let targetSize = CGSize(width: 32, height: 32)
        view.frame.size = targetSize
        view.centerOffset = CGPoint(x: 0, y: -targetSize.height / 2)
        view.image = UIImage(systemName: "mappin.circle.fill")?.scaled(to: targetSize)

        if let url = URL(string: viewModel.iconURLString) {
            imageLoader.load(url: url, targetSize: targetSize) { [weak view] image in
                guard let v = view, let image else { return }
                v.image = image
                v.frame.size = targetSize
                v.centerOffset = CGPoint(x: 0, y: -targetSize.height / 2)
            }
        }
        return view
    }
}
