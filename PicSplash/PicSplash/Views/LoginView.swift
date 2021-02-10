//
//  LoginView.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

class LoginView: UIView {
	// internal vars
	private let topTintView: UIView = UIView(frame: .zero)
	private let loginLabel: UILabel = UILabel(frame: .zero)
	private let cancelButton: UIButton = UIButton(type: .system)
	
	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .systemYellow
				
//		layer.borderWidth = 1.0
//		layer.borderColor = UIColor.red.cgColor

		layer.cornerRadius = 10.0
		layer.masksToBounds = true

		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in LoginView")
	}
	
	
	// helpers
	private func configureSubviews() {
		topTintView.translatesAutoresizingMaskIntoConstraints = false
		topTintView.backgroundColor = .darkGray
		addSubview(topTintView)
		
		loginLabel.translatesAutoresizingMaskIntoConstraints = false
		loginLabel.text = "Login"
		loginLabel.textColor = .white
		loginLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
		topTintView.addSubview(loginLabel)
		
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.setTitle("Cancel", for: .normal)
		cancelButton.tintColor = .white
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
		topTintView.addSubview(cancelButton)
	}
	
	private func constrainSubviews() {
		topTintView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
		topTintView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		topTintView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		topTintView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		topTintView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// topTintView subviews
		loginLabel.centerXAnchor.constraint(equalTo: topTintView.centerXAnchor).isActive = true
		loginLabel.centerYAnchor.constraint(equalTo: topTintView.centerYAnchor).isActive = true
		
		cancelButton.leadingAnchor.constraint(equalTo: topTintView.leadingAnchor, constant: 16.0).isActive = true
		cancelButton.centerYAnchor.constraint(equalTo: topTintView.centerYAnchor).isActive = true
	}
}
