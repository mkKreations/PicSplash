//
//  HomeOrthogonalCell.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

class HomeOrthogonalCell: UICollectionViewCell {
	// class vars
	static let reuseIdentifier: String = UUID().uuidString
	
	
	// instance vars
	private let displayImageView: UIImageView = UIImageView(frame: .zero)
	private let gradientOverlayView: ImageShadowOverlayView = ImageShadowOverlayView(frame: .zero)
	private let displayLabel: UILabel = UILabel(frame: .zero)
	
	
	// public setters
//	var displayImage: UIImage? {
//		didSet {
//			displayImageView.image = displayImage
//		}
//	}
	
	var displayBackgroundColor: UIColor? {
		didSet {
			if let bgColor = displayBackgroundColor {
				displayImageView.backgroundColor = bgColor
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
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in HomeOrthogonalCell")
	}
	
	
	// helper methods
	private func configureSubviews() {
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.contentMode = .scaleAspectFit
		contentView.addSubview(displayImageView)
		
		gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(gradientOverlayView)
		
		displayLabel.translatesAutoresizingMaskIntoConstraints = false
		displayLabel.textColor = .white
		displayLabel.textAlignment = .center
		contentView.addSubview(displayLabel)
	}
	
	private func constrainSubviews() {
		displayImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		displayImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		displayImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		displayImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

		gradientOverlayView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		gradientOverlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		gradientOverlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		gradientOverlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

		displayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		displayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		displayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
		displayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0).isActive = true
	}
}
