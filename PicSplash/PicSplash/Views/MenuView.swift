//
//  MenuView.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

protocol MenuViewButtonsProvider: AnyObject {
	func didPressDoneButton(_ button: UIButton)
	func didPressMenuButton(withMenuOption menuOption: MenuOption)
}

// this view will be used to remove view-related
// code from MenuViewController

class MenuView: UIView {
	// instance vars
	private let doneButton: UIButton = UIButton(type: .system)
	private let topView: MenuTopView = MenuTopView(frame: .zero)
	private let topStackView: UIStackView = UIStackView(frame: .zero)
	private let topDivider: UIView = UIView(frame: .zero)
	private let bottomStackView: UIStackView = UIStackView(frame: .zero)
	private let bottomDivider: UIView = UIView(frame: .zero)
	weak var delegate: MenuViewButtonsProvider?

	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .picSplashBlack
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in MenuView")
	}
	
	
	// helpers methods
	private func configureSubviews() {
		doneButton.translatesAutoresizingMaskIntoConstraints = false
		doneButton.tintColor = .white
		doneButton.setTitle("Done", for: .normal)
		doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
		doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
		addSubview(doneButton)
		
		topView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(topView)
		
		topStackView.translatesAutoresizingMaskIntoConstraints = false
		// instantiate top buttons
		let topButtons: [UIButton] = [MenuOption.recommend, MenuOption.review].map { menuOption in
			let button = UIButton.createButton(forMenuOption: menuOption)
			button.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
			return button
		}
		topButtons.forEach { topStackView.addArrangedSubview($0) } // add buttons to topStackView
		topStackView.axis = .vertical
		topStackView.distribution = .fill
		topStackView.alignment = .leading
		topStackView.spacing = 16.0
		addSubview(topStackView)

		topDivider.translatesAutoresizingMaskIntoConstraints = false
		topDivider.backgroundColor = .darkGray
		addSubview(topDivider)
		
		bottomStackView.translatesAutoresizingMaskIntoConstraints = false
		// instantiate bottom buttons
		let bottomButtons: [UIButton] = [MenuOption.visit, MenuOption.license].map { menuOption in
			let button = UIButton.createButton(forMenuOption: menuOption)
			button.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
			return button
		}
		bottomButtons.forEach { bottomStackView.addArrangedSubview($0) } // add buttons to bottomStackView
		bottomStackView.axis = .vertical
		bottomStackView.distribution = .fill
		bottomStackView.alignment = .leading
		bottomStackView.spacing = 16.0
		addSubview(bottomStackView)
		
		bottomDivider.translatesAutoresizingMaskIntoConstraints = false
		bottomDivider.backgroundColor = .darkGray
		addSubview(bottomDivider)
	}
	
	private func constrainSubviews() {
		doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 5.0).isActive = true
		doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true

		topView.topAnchor.constraint(equalTo: topAnchor, constant: 50.0).isActive = true
		topView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		topStackView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 50.0).isActive = true
		topStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		topStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
		
		topDivider.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 16.0).isActive = true
		topDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		topDivider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		topDivider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
		
		bottomStackView.topAnchor.constraint(equalTo: topDivider.bottomAnchor, constant: 16.0).isActive = true
		bottomStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		bottomStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
		
		bottomDivider.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 16.0).isActive = true
		bottomDivider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		bottomDivider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		bottomDivider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
	}
	
	
	// button actions
	@objc private func doneButtonPressed(_ sender: UIButton) {
		delegate?.didPressDoneButton(sender)
	}
	
	@objc private func menuButtonPressed(_ sender: UIButton) {
		// ensure we have a valid MenuOption
		guard let selectedMenuOption = MenuOption(rawValue: sender.tag) else { return }
		delegate?.didPressMenuButton(withMenuOption: selectedMenuOption)
	}
}
