//
//  MenuViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

class MenuViewController: UIViewController {
	private let topView: MenuTopView = MenuTopView(frame: .zero)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .picsplashBlack

		configureSubviews()
		constrainSubviews()
	}
	
	
	// MARK: view helpers
	
	private func configureSubviews() {
		topView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(topView)
	}
	
	private func constrainSubviews() {
		topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
		topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}
}
