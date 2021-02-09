//
//  MenuButton.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

// enum to organize our menu options

enum MenuOption: String {
	case recommend = "Recommend PicSplash"
	case review = "Write a review"
	case visit = "Visit picsplash.com"
	case license = "License"
}

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
	
		setTitle(self.menuOption.rawValue, for: .normal)
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
