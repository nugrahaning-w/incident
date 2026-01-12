//
//  IncidentTableViewCell.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import UIKit
import SnapKit

final class IncidentTableViewCell: UITableViewCell {

    // MARK: - Identifier

    static let identifier = "IncidentTableViewCell"

    // MARK: - UI Components

    private let containerView = UIView()

    private let iconImageView = UIImageView()
    private let iconLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let stackView = UIStackView()

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusBadgeLabel = PaddingLabel()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemGroupedBackground

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label

        iconLoadingIndicator.hidesWhenStopped = true
        
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .leading

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .black

        statusBadgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusBadgeLabel.textColor = .white
        statusBadgeLabel.layer.cornerRadius = 6
        statusBadgeLabel.layer.masksToBounds = true

        // Ensure intrinsic width is respected
        statusBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(iconLoadingIndicator)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(statusBadgeLabel)
    }

    private func setupConstraints() {
        // SnapKit constraints
        
        // Container
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).inset(16)
            make.bottom.equalTo(contentView).inset(8)
        }
        
        // Icon
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(12)
            make.centerY.equalTo(containerView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        iconLoadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(iconImageView)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).inset(8)
            make.top.equalTo(containerView.snp.top).offset(8)
            make.bottom.equalTo(containerView.snp.bottom).inset(8)
        }
    }

    // MARK: - Configure

    func configure(with incident: Incident) {
        titleLabel.text = incident.title
        dateLabel.text = incident.lastUpdated.incidentFormatted

        statusBadgeLabel.text = incident.status.rawValue
        statusBadgeLabel.backgroundColor = incident.status.color

        loadIcon(from: incident.iconURL)
    }

    // MARK: - Image Loading

    private func loadIcon(from url: URL) {
        iconImageView.image = nil
        iconLoadingIndicator.startAnimating()

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                self?.iconLoadingIndicator.stopAnimating()
                if let data = data {
                    self?.iconImageView.image = UIImage(data: data)
                } else {
                    self?.iconImageView.image = UIImage(systemName: "exclamationmark.triangle")
                }
            }
        }.resume()
    }
}
