//
//  HomeImageCell.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

class HomeImageCell: UICollectionViewCell {
	// class vars
	static let reuseIdentifier: String = UUID().uuidString
	static let imageShadowOverlayStyle: ImageShadowOverlayView.OverlayStyle = .base
	
	
	// instance vars - exposed to public for view controller transition
	let gradientOverlayView: ImageShadowOverlayView = ImageShadowOverlayView(overlayStyle: HomeImageCell.imageShadowOverlayStyle)
	let displayImageView: UIImageView = UIImageView(frame: .zero)
	let displayLabel: UILabel = UILabel(frame: .zero)
	private var imageViewHeightConstraint: NSLayoutConstraint! // manage imageView height manually
	private let loader: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
	
		
	// public setters
	var displayImage: UIImage? {
		didSet {
			displayImageView.image = displayImage
		}
	}
	
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
				
				handleImageViewHeightConstraint(forText: text)
			}
		}
	}
	
	var imageHeight: Int? {
		didSet {
			if let height = imageHeight {
				imageViewHeightConstraint.constant = CGFloat(height)
			}
		}
	}
	
	// currently not using as we're
	// presenting the blurHash image
	// when the actual image is loading
	var isLoading: Bool {
		get { self.loader.isAnimating }
		
		set(newValue) {
			newValue == true ? self.loader.startAnimating() : self.loader.stopAnimating()
		}
	}
	
	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.backgroundColor = .picSplashBlack
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in HomeImageCell")
	}
	
	
	// helper methods
	private func configureSubviews() {
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.contentMode = .scaleAspectFill
		displayImageView.clipsToBounds = true
		contentView.addSubview(displayImageView)
		
		gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(gradientOverlayView)
		
		displayLabel.translatesAutoresizingMaskIntoConstraints = false
		displayLabel.textColor = .white
		contentView.addSubview(displayLabel)
		
		loader.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(loader)
	}
	
	private func constrainSubviews() {
		displayImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		displayImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1.0).isActive = true
		displayImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		displayImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		imageViewHeightConstraint = displayImageView.heightAnchor.constraint(equalToConstant: 0.0)
		imageViewHeightConstraint.isActive = true

		gradientOverlayView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		gradientOverlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1.0).isActive = true
		gradientOverlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		gradientOverlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

		displayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0).isActive = true
		displayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5.0).isActive = true
		displayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0).isActive = true
		
		loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
	}
	
	// keeping this logic separate
	private func handleImageViewHeightConstraint(forText text: String) {
		guard let height = Int(text) else { return }
		imageViewHeightConstraint.constant = CGFloat(height)
	}
}
