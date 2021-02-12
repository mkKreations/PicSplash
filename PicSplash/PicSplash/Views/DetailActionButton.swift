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
//		overlayButton.layer.borderWidth = 1.0
//		overlayButton.layer.borderColor = UIColor.blue.cgColor
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
		print(detailAction)
		delegate?.didPressDetailActionButton(detailAction)
	}
	
}
