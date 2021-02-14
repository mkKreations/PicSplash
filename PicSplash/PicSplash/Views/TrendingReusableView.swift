//
//  TrendingReusableView.swift
//  PicSplash
//
//  Created by Marcus on 2/13/21.
//

import UIKit

class TrendingReusableView: UICollectionReusableView {
	// class vars
	static let reuseIdentifier: String = UUID().uuidString
	
	
	// instance vars
	private let displayLabel: UILabel = UILabel(frame: .zero)
	
		
	// setters
	var displayText: String? {
		didSet {
			displayLabel.text = displayText
		}
	}
	

	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		displayLabel.translatesAutoresizingMaskIntoConstraints = false
		displayLabel.numberOfLines = 1
		displayLabel.textColor = .white
		displayLabel.font = UIFont.systemFont(ofSize: 26.0, weight: .bold)
		addSubview(displayLabel)

		displayLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		displayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		displayLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in TrendingReusableView")
	}
}
