//
//  MenuView.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

protocol MenuViewButtonsProvider: AnyObject {
	func didPressDoneButton(_ button: UIButton)
}

// this view will be used to remove view-related
// code from MenuViewController

class MenuView: UIView {
	// instance vars
	private let doneButton: UIButton = UIButton(type: .system)
	private let topView: MenuTopView = MenuTopView(frame: .zero)
	weak var delegate: MenuViewButtonsProvider?

	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .picsplashBlack
		
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
	}
	
	private func constrainSubviews() {
		doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 5.0).isActive = true
		doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true

		topView.topAnchor.constraint(equalTo: topAnchor, constant: 50.0).isActive = true
		topView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
	}
	
	
	// button actions
	@objc private func doneButtonPressed(_ sender: UIButton) {
		delegate?.didPressDoneButton(sender)
	}
}
