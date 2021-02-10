//
//  LoginView.swift
//  PicSplash
//
//  Created by Marcus on 2/9/21.
//

import UIKit

// delegation to manage button actions

protocol LoginViewButtonActionsProvider: AnyObject {
	func didPressCancelButton(_ sender: UIButton)
}


class LoginView: UIView {
	// internal vars
	private let topTintView: UIView = UIView(frame: .zero)
	private let loginLabel: UILabel = UILabel(frame: .zero)
	private let cancelButton: UIButton = UIButton(type: .system)
	private let topTintViewDivider: UIView = UIView(frame: .zero)
	private let bottomContainerView: UIView = UIView(frame: .zero)
	private let bottomStackView: UIStackView = UIStackView(frame: .zero)
	private let loginButton: UIButton = UIButton(type: .system)
	private let forgotPasswordButton: UIButton = UIButton(type: .system)
	private let noAccountJoinButton: UIButton = UIButton(type: .system)
	weak var delegate: LoginViewButtonActionsProvider?
	
	
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
		// topTintView and its subviews
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
		cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
		topTintView.addSubview(cancelButton)
		
		topTintViewDivider.translatesAutoresizingMaskIntoConstraints = false
		topTintViewDivider.backgroundColor = .lightGray
		addSubview(topTintViewDivider)
		
		// bottomContainerView
		bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
		bottomContainerView.backgroundColor = .picsplashBlack
		addSubview(bottomContainerView)
		
		// instantiate textFields
		let textFieldStates: [LoginTextFieldState] = [.email, .password]
		let textFields: [LoginTextField] = textFieldStates.map { state in
			let textField = LoginTextField(textFieldState: state)
			return textField
		}
		
		// bottomStackView and its subviews
		bottomStackView.translatesAutoresizingMaskIntoConstraints = false
		textFields.forEach { bottomStackView.addArrangedSubview($0) }
		[loginButton, forgotPasswordButton, noAccountJoinButton].forEach { bottomStackView.addArrangedSubview($0) }
		bottomStackView.axis = .vertical
		bottomStackView.distribution = .fill
		bottomStackView.spacing = 20.0
		bottomContainerView.addSubview(bottomStackView)
				
		loginButton.backgroundColor = .white
		loginButton.setTitle("Log In", for: .normal)
		loginButton.setTitleColor(.picsplashBlack, for: .normal)
		loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
		loginButton.layer.cornerRadius = 4.0
		loginButton.layer.masksToBounds = true
		
		forgotPasswordButton.setTitle("Forgot your password?", for: .normal)
		forgotPasswordButton.setTitleColor(.white, for: .normal)
		forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
		
		let attributedTitle = NSMutableAttributedString() // configure attributed string for noAccountJoinButton
		let noAccountAttrs: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 18.0),
			.foregroundColor: UIColor.white,
		]
		let joinAttrs: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
			.foregroundColor: UIColor.white,
		]
		attributedTitle.append(NSAttributedString(string: "Don't have an account?", attributes: noAccountAttrs))
		attributedTitle.append(NSAttributedString(string: " Join", attributes: joinAttrs))
		noAccountJoinButton.setAttributedTitle(attributedTitle, for: .normal)
	}
	
	private func constrainSubviews() {
		topTintView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
		topTintView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		topTintView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		topTintView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		// topTintView subviews
		let topTintViewSubviewConstraints = [
			loginLabel.centerXAnchor.constraint(equalTo: topTintView.centerXAnchor),
			loginLabel.centerYAnchor.constraint(equalTo: topTintView.centerYAnchor),
			
			cancelButton.leadingAnchor.constraint(equalTo: topTintView.leadingAnchor, constant: 16.0),
			cancelButton.centerYAnchor.constraint(equalTo: topTintView.centerYAnchor),
			
			topTintViewDivider.heightAnchor.constraint(equalToConstant: 1.0),
			topTintViewDivider.leadingAnchor.constraint(equalTo: topTintView.leadingAnchor),
			topTintViewDivider.trailingAnchor.constraint(equalTo: topTintView.trailingAnchor),
			topTintViewDivider.bottomAnchor.constraint(equalTo: topTintView.bottomAnchor),
		]
		NSLayoutConstraint.activate(topTintViewSubviewConstraints)
		
		bottomContainerView.topAnchor.constraint(equalTo: topTintView.bottomAnchor).isActive = true
		bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		// bottomContainerView subviews
		let bottomContainerViewSubviewConstraints = [
			bottomStackView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 40.0),
			bottomStackView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16.0),
			bottomStackView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16.0),
			bottomStackView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -30.0),

			loginButton.heightAnchor.constraint(equalToConstant: 40.0),
			
			forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30.0),
		]
		NSLayoutConstraint.activate(bottomContainerViewSubviewConstraints)
	}
	
	
	// button actions
	@objc private func cancelButtonPressed(_ sender: UIButton) {
		delegate?.didPressCancelButton(sender)
	}
	
}
