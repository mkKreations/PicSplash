//
//  MenuTopView.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

class MenuTopView: UIView {
	// class vars
	private static let imageDimension: CGFloat = 30.0
	
	
	// instance vars
	private let stackView: UIStackView = UIStackView(frame: .zero)
	private let displayImageView: UIImageView = UIImageView(frame: .zero)
	private let titleLabel: UILabel = UILabel(frame: .zero)
	private let versionLabel: UILabel = UILabel(frame: .zero)
	
	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in MenuTopView")
	}
	
	
	// helpers
	private func configureSubviews() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		[displayImageView, titleLabel, versionLabel].forEach { stackView.addArrangedSubview($0) }
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = 8.0
		stackView.setCustomSpacing(10.0, after: displayImageView) // keep it pretty
		addSubview(stackView)
		
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.contentMode = .scaleAspectFit
		displayImageView.backgroundColor = UIColor.systemYellow
		
		titleLabel.text = "PicSplash"
		titleLabel.textColor = .white
		titleLabel.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)

		versionLabel.text = "v2.0 (89)"
		versionLabel.textColor = .gray
		versionLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
	}
	
	private func constrainSubviews() {
		displayImageView.heightAnchor.constraint(equalToConstant: Self.imageDimension).isActive = true
		displayImageView.widthAnchor.constraint(equalTo: displayImageView.heightAnchor).isActive = true

		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
}
