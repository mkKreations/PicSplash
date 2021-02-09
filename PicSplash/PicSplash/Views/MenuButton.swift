//
//  MenuButton.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

// enum to organize our menu options


// just set MenuOption on button via
// designated init and title will be
// set automatically

class MenuButton: UIButton {
	// instance vars
	let menuOption: MenuOption

	
	// inits
	init(menuOption: MenuOption) {
		self.menuOption = menuOption
		super.init(frame: .zero)
	
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.systemYellow.cgColor
//		titleLabel?.textAlignment = .left
//		setTitle(self.menuOption.rawValue, for: .normal)
		setTitleColor(.white, for: .normal)
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in MenuButton")
	}
	
	
	// getter overrides
	override var buttonType: UIButton.ButtonType {
		.system
	}
}
