//
//  MenuViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

class MenuViewController: UIViewController {
	private let topView: MenuTopView = MenuTopView(frame: .zero)
	
	override func loadView() {
		// good opportunity to remove view code from this view controller
		let menuView = MenuView()
		menuView.delegate = self // respond to button actions
		view = menuView
	}
	
}

extension MenuViewController: MenuViewButtonsProvider {
	func didPressDoneButton(_ button: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	
	func didPressMenuButton(withMenuOption menuOption: MenuOption) {
		switch menuOption {
		case .recommend:
			print("Recommend!")
		case .review:
			print("Review!")
		case .visit:
			print("Visit!")
		case .license:
			print("License!")
		}
	}
}
