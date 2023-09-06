//
//  SearchResultCell.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-29.
//

import Foundation
import UIKit

final class SearchResultCell: UITableViewCell {
    
    private var imageLoadingTask: Task<Void, Error>? = nil

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
        imageLoadingTask?.cancel()
 
    }
        
    var viewModel: SearchResultCellViewModel? {
        didSet {
            guard let viewModel else { return }
            self.configure(with: viewModel)
            self.loadImage(with: viewModel)
        }
    }
    
    private func loadImage(with viewModel: SearchResultCellViewModel) {
        imageLoadingTask = Task(priority: .utility) {
            do {
                async let image = viewModel.retrieveImage()
                self.titleImageView.image = try await image ?? placeholderImage
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private struct LayoutConstants {
        static let stackViewSpacing: CGFloat = 5.0
        static let contentDimension: CGFloat = 150
        static let margin: CGFloat = 8.0
    }
    
    private lazy var spacerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = placeholderImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 6.0
        return imageView
    }()
    
    private lazy var titleImageViewWidthConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: titleImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: LayoutConstants.contentDimension)
    }()
    
    private var titleImageConstraints: [NSLayoutConstraint] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private lazy var narratorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = LayoutConstants.stackViewSpacing
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(authorLabel)
        labelsStackView.addArrangedSubview(narratorLabel)
        labelsStackView.setCustomSpacing(10.0, after: titleLabel)

        spacerView.addSubview(titleImageView)
        contentView.addSubview(spacerView)
        contentView.addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.margin),
            spacerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: LayoutConstants.contentDimension),
            spacerView.widthAnchor.constraint(equalToConstant: LayoutConstants.contentDimension),
            titleImageView.centerYAnchor.constraint(equalTo: spacerView.centerYAnchor),
            titleImageView.centerXAnchor.constraint(equalTo: spacerView.centerXAnchor),
            titleImageViewWidthConstraint,
            titleImageView.heightAnchor.constraint(equalTo: spacerView.heightAnchor, multiplier: 1),
            labelsStackView.heightAnchor.constraint(lessThanOrEqualToConstant: LayoutConstants.contentDimension),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: titleImageView.trailingAnchor, constant: LayoutConstants.margin),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.margin),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with viewModel: SearchResultCellViewModel) {
        titleLabel.text = viewModel.title
        authorLabel.text = viewModel.authors
        narratorLabel.text = viewModel.narrators

        authorLabel.isHidden = viewModel.authors.isEmpty
        narratorLabel.isHidden = viewModel.narrators.isEmpty
        
        titleImageViewWidthConstraint.constant *= viewModel.imageAspectRatio
        setNeedsLayout()
    }
    
    private func reset() {
        viewModel = nil
        titleLabel.text = nil
        narratorLabel.text = nil
        titleImageView.image = placeholderImage
        titleImageViewWidthConstraint.constant = LayoutConstants.contentDimension
        setNeedsLayout()
    }
    
    private let placeholderImage = UIImage(systemName: "questionmark.circle.fill")

    static func reuseIdentifier() -> String {
        String(describing: self)
    }
}
