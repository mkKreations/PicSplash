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
		view = MenuView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
}
