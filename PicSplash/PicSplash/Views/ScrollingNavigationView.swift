//
//  ScrollingNavigationView.swift
//  PicSplash
//
//  Created by Marcus on 2/7/21.
//

import UIKit

class ScrollingNavigationView: UIView {
	// static vars
	private static let buttonDimension: CGFloat = 40.0
	
	
	// instance vars
	private let vertStackView: UIStackView = UIStackView(frame: .zero)
	private let displayLabel: UILabel = UILabel(frame: .zero)
	private let searchBar: UISearchBar = UISearchBar(frame: .zero)
	private let displayImageView: UIImageView = UIImageView(frame: .zero)
	private let gradientOverlayView: ImageShadowOverlayView = ImageShadowOverlayView(overlayStyle: .full)
	private let buttonsStackView: UIStackView = UIStackView(frame: .zero)
	private let rightBarButton: UIButton = UIButton(type: .system)
	private let leftBarButton: UIButton = UIButton(type: .system)

	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .systemYellow
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in ScrollingNavigationView")
	}
	
	
	// public
	func animateSubviews(forScrollDelta scrollDelta: CGFloat) {
		displayLabel.alpha = scrollDelta
		buttonsStackView.alpha = scrollDelta
	}
	
	
	// helpers
	private func configureSubviews() {
		displayImageView.image = UIImage(named: "Coffee")
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.contentMode = .scaleAspectFill
		displayImageView.clipsToBounds = true
		addSubview(displayImageView)
		
		gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientOverlayView)
		
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		[leftBarButton, rightBarButton].forEach { buttonsStackView.addArrangedSubview($0) }
		buttonsStackView.axis = .horizontal
		buttonsStackView.distribution = .fill
		addSubview(buttonsStackView)
		
		// symbol config to set point size for SF symbol image
		let sfSymbolConfig = UIImage.SymbolConfiguration(pointSize: 22.0)

		leftBarButton.translatesAutoresizingMaskIntoConstraints = false
		leftBarButton.setImage(UIImage(systemName: "person.circle", withConfiguration: sfSymbolConfig), for: .normal)
		leftBarButton.tintColor = .white

		rightBarButton.translatesAutoresizingMaskIntoConstraints = false
		rightBarButton.setImage(UIImage(systemName: "rectangle.stack", withConfiguration: sfSymbolConfig), for: .normal)
		rightBarButton.tintColor = .white

		vertStackView.translatesAutoresizingMaskIntoConstraints = false
		vertStackView.spacing = 0.0
		[displayLabel, searchBar].forEach { vertStackView.addArrangedSubview($0) }
		vertStackView.axis = .vertical
		vertStackView.distribution = .fill
		addSubview(vertStackView)
		
		displayLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .bold)
		displayLabel.textColor = .white
		displayLabel.numberOfLines = 1
		displayLabel.textAlignment = .center
		displayLabel.text = "Photos for everyone"
		displayLabel.setContentHuggingPriority(.required, for: .vertical)

		// set placeholder text with attributed string
		// to also set placeholder text color
		searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Photos",
																																				 attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
		searchBar.searchBarStyle = .minimal
		searchBar.searchTextField.leftView?.tintColor = .white // set magnifying glass tintColor
	}
	
	private func constrainSubviews() {
		displayImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		displayImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		displayImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		displayImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		gradientOverlayView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		gradientOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		gradientOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		gradientOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20.0).isActive = true
		buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0).isActive = true
		buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0).isActive = true
		buttonsStackView.heightAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		
		leftBarButton.widthAnchor.constraint(equalTo: buttonsStackView.heightAnchor).isActive = true

		rightBarButton.widthAnchor.constraint(equalTo: leftBarButton.widthAnchor).isActive = true

		vertStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0).isActive = true
		vertStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0).isActive = true
		vertStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
				
		// willing to break this constraint to satisfy bottom constraint
		let centerYStackViewConstraint = vertStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15.0)
		centerYStackViewConstraint.priority = UILayoutPriority(500)
		centerYStackViewConstraint.isActive = true
		
		// always respect bottomAnchor constraint with high priority
		let bottomStackViewConstraint = vertStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0.0)
		bottomStackViewConstraint.priority = UILayoutPriority(999)
		bottomStackViewConstraint.isActive = true
	}
		
}
