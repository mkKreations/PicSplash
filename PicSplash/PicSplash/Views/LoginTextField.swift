//
//  LoginTextField.swift
//  PicSplash
//
//  Created by Marcus on 2/10/21.
//

import UIKit

// enum to represent different textField states
enum LoginTextFieldState: String {
	case email = "Email"
	case password = "Password"
}

class LoginTextField: UIView {
	// internal vars
	private let stackView: UIStackView = UIStackView(frame: .zero)
	private let textField: UITextField = UITextField(frame: .zero)
	private let divider: UIView = UIView(frame: .zero)
	let textFieldState: LoginTextFieldState
	
	
	// inits
	init(textFieldState: LoginTextFieldState) {
		self.textFieldState = textFieldState

		super.init(frame: .zero)

		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in LoginTextField")
	}
	
	
	// helpers
	private func configureSubviews() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		[textField, divider].forEach { stackView.addArrangedSubview($0) }
		stackView.axis = .vertical
		stackView.distribution = .fill
		addSubview(stackView)
		
		textField.backgroundColor = .systemYellow
		textField.placeholder = textFieldState.rawValue
		
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .systemGreen
	}
	
	private func constrainSubviews() {
		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
	}
}
