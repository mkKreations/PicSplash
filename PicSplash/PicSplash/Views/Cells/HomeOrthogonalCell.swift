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
	private let gradientOverlayView: ImageShadowOverlayView = ImageShadowOverlayView(overlayStyle: .full(0.4))
	private let displayLabel: UILabel = UILabel(frame: .zero)
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
		
		// apply cornerRadius to layer & masksToBounds
		layer.cornerRadius = 14.0
		layer.masksToBounds = true
		
		configureSubviews()
		constrainSubviews()
		addLongPressGestureRecognizer()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in HomeOrthogonalCell")
	}
	
	
	// helper methods
	private func configureSubviews() {
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.contentMode = .scaleAspectFill
		contentView.addSubview(displayImageView)
		
		gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(gradientOverlayView)
		
		displayLabel.translatesAutoresizingMaskIntoConstraints = false
		displayLabel.textColor = .white
		displayLabel.textAlignment = .center
		displayLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
		contentView.addSubview(displayLabel)
		
		loader.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(loader)
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
		displayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
		displayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0).isActive = true
		
		loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
	}

	// long press gesture
	
	private func addLongPressGestureRecognizer() {
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
		longPress.minimumPressDuration = 0.08
		longPress.delaysTouchesBegan = false
		contentView.addGestureRecognizer(longPress)
	}
	
	@objc private func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
		let isTouching = sender.state == .began
		animateSelection(forIsTouching: isTouching)
	}
	
	private func animateSelection(forIsTouching isTouching: Bool) {
		UIView.animate(withDuration: 0.5,
									 delay: 0.0,
									 usingSpringWithDamping: 1.0,
									 initialSpringVelocity: 5.0,
									 options: [.allowUserInteraction],
									 animations: {
										self.transform = isTouching ? .init(scaleX: 0.95, y: 0.95) : .identity
									 },
									 completion: nil)
	}
}
