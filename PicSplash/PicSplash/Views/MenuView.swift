//
//  MenuView.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

// this view will be used to remove view-related
// code from MenuViewController

class MenuView: UIView {
	// instance vars
	private let topView: MenuTopView = MenuTopView(frame: .zero)

	
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
		topView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(topView)
	}
	
	private func constrainSubviews() {
		topView.topAnchor.constraint(equalTo: topAnchor, constant: 40.0).isActive = true
		topView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
	}
}
