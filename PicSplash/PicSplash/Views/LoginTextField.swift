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


// protocol to pass work to delegate(s)
protocol LoginTextFieldActionsProvider: AnyObject {
	func userDidPressReturn(withTextFieldState textFieldState: LoginTextFieldState)
}


// subclassing UITextField to reposition its
// rightView's property bounds manually

fileprivate class RightImageTextField: UITextField {
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in RightImageTextField")
	}
	
	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: bounds.size.width - 30.0, y: -2.0, width: 26.0, height: 24.0)
	}
}


// actual class we'll be working with

class LoginTextField: UIView {
	// internal vars
	private let stackView: UIStackView = UIStackView(frame: .zero)
	private let textField: RightImageTextField = RightImageTextField(frame: .zero)
	private let divider: UIView = UIView(frame: .zero)
	let textFieldState: LoginTextFieldState
	weak var delegate: LoginTextFieldActionsProvider?
	
	
	// computed vars
	var isCurrentFirstResponder: Bool {
		// RightImageTextField is fileprivate so
		// we can't expose textField so we create
		// our own var to do the task
		textField.isFirstResponder
	}
	
	
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
	
	
	// public helpers
	func makeFirstResponder() {
		textField.becomeFirstResponder()
	}
	
	func endFirstResponder() {
		textField.resignFirstResponder()
	}
	
	
	// private helpers
	private func configureSubviews() {
		stackView.translatesAutoresizingMaskIntoConstraints = false
		[textField, divider].forEach { stackView.addArrangedSubview($0) }
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.spacing = 10.0
		addSubview(stackView)
		
		textField.font = UIFont.systemFont(ofSize: 16.0)
		textField.delegate = self
		textField.returnKeyType = textFieldState == .email ? .next : .done
		textField.tintColor = .white // for white cursor
		textField.keyboardAppearance = .dark
		textField.attributedPlaceholder = NSAttributedString(string: textFieldState.rawValue,
																												 attributes: [.foregroundColor: UIColor.white])
		
		if textFieldState == .password { // add lock icon
			textField.rightViewMode = .always
			let lockImageView = UIImageView(image: UIImage(systemName: "lock.circle"))
			lockImageView.tintColor = .lightGray
			textField.rightView = lockImageView
		}
		
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .darkGray
	}
	
	private func constrainSubviews() {
		stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
	}
}


// MARK: textField delegate

extension LoginTextField: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// initial state
		divider.backgroundColor = .darkGray
		
		UIView.animate(withDuration: 0.3) {
			self.divider.backgroundColor = .white
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		// initial state
		divider.backgroundColor = .white
		
		UIView.animate(withDuration: 0.3) {
			self.divider.backgroundColor = .darkGray
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		delegate?.userDidPressReturn(withTextFieldState: textFieldState)
		return true
	}
}
