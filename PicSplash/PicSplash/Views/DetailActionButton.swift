//
//  DetailActionButton.swift
//  PicSplash
//
//  Created by Marcus on 2/12/21.
//

import UIKit

// delegate button action
protocol DetailActionButtonsProvider: AnyObject {
	func didPressDetailActionButton(_ detailAction: DetailAction)
}

// enum to represent different actions

enum DetailAction {
	case like
	case add
	case download
	case scroll
}

class DetailActionButton: UIView {
	// class vars
	static private let buttonDimension: CGFloat = 60.0
	
	
	// instance vars
	private let displayImageView: UIImageView = UIImageView(frame: .zero)
	private let overlayButton: UIButton = UIButton(type: .custom)
	let detailAction: DetailAction
	weak var delegate: DetailActionButtonsProvider?


	// computed vars
	private var sfSymbolImage: UIImage? {
		let largeConfig = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold, scale: .large)
		switch detailAction {
		case .like:
			return UIImage(systemName: "heart.fill", withConfiguration: largeConfig)
		case .add:
			return UIImage(systemName: "plus", withConfiguration: largeConfig)
		case .download:
			return UIImage(systemName: "arrow.down", withConfiguration: largeConfig)
		case .scroll:
			return UIImage(systemName: "arrow.up", withConfiguration: largeConfig)
		}
	}
	

	// inits
	init(detailAction: DetailAction) {
		self.detailAction = detailAction
		super.init(frame: .zero)
		
		// configure view itself
		backgroundColor = detailAction == .download ? .white : .picSplashLightBlack
		layer.cornerRadius = Self.buttonDimension / 2.0
		layer.masksToBounds = true
		layer.borderColor = detailAction == .scroll ? UIColor.white.withAlphaComponent(0.8).cgColor : nil
		layer.borderWidth = detailAction == .scroll ? 2.0 : 0.0
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in DetailActionButton")
	}
	
	
	// helpers
	private func configureSubviews() {
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.image = sfSymbolImage
		displayImageView.tintColor = detailAction == .download ? .picSplashBlack : .white
		addSubview(displayImageView)
		
		overlayButton.translatesAutoresizingMaskIntoConstraints = false
		overlayButton.layer.cornerRadius = Self.buttonDimension / 2.0
		overlayButton.addTarget(self, action: #selector(overlayButtonPressed), for: .touchUpInside)
		addSubview(overlayButton)
	}
	
	private func constrainSubviews() {
		heightAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		widthAnchor.constraint(equalTo: heightAnchor).isActive = true
		
		displayImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		displayImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		overlayButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		overlayButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		overlayButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
		overlayButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}
		
	@objc private func overlayButtonPressed(_ sender: UIButton) {
		let animationDuration: TimeInterval = 0.04
		
		// scale
		UIView.animate(withDuration: animationDuration,
									 animations: {
										self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
									 },
									 completion: { _ in
										
										// return back to size
										UIView.animate(withDuration: animationDuration) {
											self.transform = CGAffineTransform.identity
										} completion: { _ in
											// pass action
											self.delegate?.didPressDetailActionButton(self.detailAction)
										}
										
									 })
	}
	
}
