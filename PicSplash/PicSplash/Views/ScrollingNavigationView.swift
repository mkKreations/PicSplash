//
//  ScrollingNavigationView.swift
//  PicSplash
//
//  Created by Marcus on 2/7/21.
//

import UIKit

class ScrollingNavigationView: UIView {
	// instance vars
	private let vertStackView: UIStackView = UIStackView(frame: .zero)
	private let displayLabel: UILabel = UILabel(frame: .zero)
	private let searchBar: UISearchBar = UISearchBar(frame: .zero)

	
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
	}
	
	
	// helpers
	private func configureSubviews() {
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
