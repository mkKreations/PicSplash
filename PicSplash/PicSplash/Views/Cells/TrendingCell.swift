//
//  TrendingCell.swift
//  PicSplash
//
//  Created by Marcus on 2/13/21.
//

import UIKit

class TrendingCell: UICollectionViewCell {
	// class vars
	static let reuseIdentifier: String = UUID().uuidString
	
	// instance vars
	private let displayLabel: UILabel = UILabel(frame: .zero)
	private let divider: UIView = UIView(frame: .zero)
	
	// setters
	var displayText: String? {
		didSet {
			displayLabel.text = displayText
		}
	}
	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
			
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in TrendingCell")
	}
	
	// helpers
	private func configureSubviews() {
		displayLabel.translatesAutoresizingMaskIntoConstraints = false
		displayLabel.numberOfLines = 1
		displayLabel.textColor = .white
		displayLabel.font = UIFont.preferredFont(forTextStyle: .title1)
		contentView.addSubview(displayLabel)
		
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .darkGray
		contentView.addSubview(divider)
	}
	
	private func constrainSubviews() {
		displayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		displayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
		displayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0).isActive = true
		
		divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
		divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
	}
}
