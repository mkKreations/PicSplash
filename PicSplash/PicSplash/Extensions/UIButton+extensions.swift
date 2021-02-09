//
//  UIButton+extensions.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

// enum to organize our menu options

enum MenuOption: Int {
	// will use Int raw values to set tag of self so
	// MenuOption can be retrieved from any UIButton
	case recommend = 23434
	case review = 34323
	case visit = 77281
	case license = 43323
	
	static func title(forMenuOption menuOption: MenuOption) -> String {
		switch menuOption {
		case .recommend:
			return "Recommend PicSplash"
		case .review:
			return "Write a review"
		case .visit:
			return "Visit picsplash.com"
		case .license:
			return "License"
		}
	}
}


// extending UIButton because we can't set
// UIButton.UIButtonType in a subclass

extension UIButton {
	static func createButton(forMenuOption menuOption: MenuOption) -> UIButton {
		let button = UIButton(type: .system)
		button.tag = menuOption.rawValue
		button.setTitle(MenuOption.title(forMenuOption: menuOption), for: .normal)
		button.setTitleColor(.white, for: .normal)
		return button
	}
}
