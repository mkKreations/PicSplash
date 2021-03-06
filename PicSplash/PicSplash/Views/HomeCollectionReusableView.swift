//
//  HomeCollectionReusableView.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

class HomeCollectionReusableView: UICollectionReusableView {
	// static vars
	static let reuseIdentifier: String = UUID().uuidString
	
	
	// instance vars
	private let displayLabel: UILabel = UILabel(frame: .zero)
	
	
	// enum to represent our different styles
	enum DisplayStyle {
		case large
		case small
	}
	
	
	// public setters
	var displayStyle: DisplayStyle = .large {
		didSet {
			switch displayStyle {
			case .large:
				displayLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
			case .small:
				displayLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
			}
		}
	}
	
	var displayText: String? {
		didSet {
			if let text = displayText {
				displayLabel.text = text
			}
		}
	}
	
	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		displayLabel.translatesAutoresizingMaskIntoConstraints = false
		displayLabel.textColor = .white
		addSubview(displayLabel)

		displayLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5.0).isActive = true
		displayLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		displayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in HomeCollectionReusableView")
	}
}
