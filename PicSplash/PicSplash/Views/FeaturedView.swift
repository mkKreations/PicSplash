//
//  FeaturedView.swift
//  PicSplash
//
//  Created by Marcus on 2/23/21.
//

import UIKit

// delegating button press tasks

protocol FeaturedViewButtonsProvider: AnyObject {
	func didPressMenuButton(_ button: UIButton)
	func didPressLogInButton(_ button: UIButton)
	func didPressSearchCancelButton(withFirstResponder firstResponder: UIView)
	func didBeginEditingSearchBar(_ searchBar: UISearchBar)
	func didSearch(withTerm term: String, andFirstResponder firstResponder: UIView)
	func didClearSearchWithNoFirstResponder()
	func didClearSearchWithFirstResponder(_ firstResponder: UIView)
}


class FeaturedView: UIView {
	// static vars
	private static let buttonDimension: CGFloat = 40.0
	
	
	// instance vars
	private let vertStackView: UIStackView = UIStackView(frame: .zero)
	private let displayLabel: UILabel = UILabel(frame: .zero)
	private let searchBar: UISearchBar = UISearchBar(frame: .zero)
	private let displayImageView: UIImageView = UIImageView(frame: .zero)
	private let gradientOverlayView: ImageShadowOverlayView = ImageShadowOverlayView(overlayStyle: .full)
	private let buttonsStackView: UIStackView = UIStackView(frame: .zero)
	private let loginButton: UIButton = UIButton(type: .system)
	private let menuButton: UIButton = UIButton(type: .system)
	weak var delegate: ScrollingNavigationButtonsProvider?
	private var shouldBeginEditing: Bool = true // to receive calls from user clicking x within search bar - see below

	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .picSplashLightBlack
		
		configureSubviews()
		constrainSubviews()
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in ScrollingNavigationView")
	}
	
	
	// public
	func animateSubviews(forScrollDelta scrollDelta: CGFloat) {
		displayLabel.alpha = scrollDelta
		buttonsStackView.alpha = scrollDelta
		displayImageView.alpha = scrollDelta
	}
	
	func setShowsCancelButton(shows: Bool, animated: Bool) {
		searchBar.setShowsCancelButton(shows, animated: animated)
	}
	
	var image: UIImage? {
		get { displayImageView.image }
		
		set {
			displayImageView.image = newValue
		}
	}
	
	
	// helpers
	private func configureSubviews() {
		displayImageView.image = UIImage(named: "Coffee")
		displayImageView.translatesAutoresizingMaskIntoConstraints = false
		displayImageView.contentMode = .scaleAspectFill
		displayImageView.clipsToBounds = true
		addSubview(displayImageView)
		
		gradientOverlayView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientOverlayView)
		
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		[menuButton, loginButton].forEach { buttonsStackView.addArrangedSubview($0) }
		buttonsStackView.axis = .horizontal
		buttonsStackView.distribution = .fill
		addSubview(buttonsStackView)
		
		// symbol config to set point size for SF symbol image for buttons
		let menuButtonSymbolConfig = UIImage.SymbolConfiguration(pointSize: 18.0)
		let loginButtonSymbolConfig = UIImage.SymbolConfiguration(pointSize: 22.0)

		menuButton.translatesAutoresizingMaskIntoConstraints = false
		menuButton.setImage(UIImage(systemName: "text.justify", withConfiguration: menuButtonSymbolConfig), for: .normal)
		menuButton.tintColor = .white
		menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)

		loginButton.translatesAutoresizingMaskIntoConstraints = false
		loginButton.setImage(UIImage(systemName: "person.circle", withConfiguration: loginButtonSymbolConfig), for: .normal)
		loginButton.tintColor = .white
		loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

		vertStackView.translatesAutoresizingMaskIntoConstraints = false
		vertStackView.spacing = 8.0
		[displayLabel, searchBar].forEach { vertStackView.addArrangedSubview($0) }
		vertStackView.axis = .vertical
		vertStackView.distribution = .fill
		addSubview(vertStackView)
		
		displayLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .bold)
		displayLabel.textColor = .white
		displayLabel.numberOfLines = 1
		displayLabel.textAlignment = .center
		displayLabel.text = "Photos for everyone"
		displayLabel.setContentHuggingPriority(.required, for: .vertical)

		// set placeholder text with attributed string
		// to also set placeholder text color
		searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Photos",
																																				 attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
		searchBar.delegate = self // respond to search events
		searchBar.searchBarStyle = .minimal
		searchBar.tintColor = .white // set Cancel button tint color
		searchBar.searchTextField.leftView?.tintColor = .white // set magnifying glass tintColor
		searchBar.searchTextField.backgroundColor = UIColor.picSplashBlack.withAlphaComponent(0.2)
		searchBar.searchTextField.delegate = self // to receive textField should clear events
	}
	
	private func constrainSubviews() {
		displayImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		displayImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		displayImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		displayImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		gradientOverlayView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		gradientOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		gradientOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		gradientOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20.0).isActive = true
		buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
		buttonsStackView.heightAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		
		menuButton.widthAnchor.constraint(equalTo: buttonsStackView.heightAnchor).isActive = true

		loginButton.widthAnchor.constraint(equalTo: menuButton.widthAnchor).isActive = true

		vertStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		vertStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
		vertStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
				
		// willing to break this constraint to satisfy bottom constraint
		let centerYStackViewConstraint = vertStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15.0)
		centerYStackViewConstraint.priority = UILayoutPriority(500)
		centerYStackViewConstraint.isActive = true
		
		// always respect bottomAnchor constraint with high priority
		let bottomStackViewConstraint = vertStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0.0)
		bottomStackViewConstraint.priority = UILayoutPriority(999)
		bottomStackViewConstraint.isActive = true
	}
	
	
	// MARK: buttons actions
	@objc private func menuButtonPressed(_ sender: UIButton) {
		delegate?.didPressMenuButton(sender)
	}

	@objc private func loginButtonPressed(_ sender: UIButton) {
		delegate?.didPressLogInButton(sender)
	}

}

extension FeaturedView: UISearchBarDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = "" // reset text
		delegate?.didPressSearchCancelButton(withFirstResponder: searchBar)
	}
		
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		delegate?.didBeginEditingSearchBar(searchBar)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchTerm = searchBar.text else { return }
		delegate?.didSearch(withTerm: searchTerm, andFirstResponder: searchBar)
	}
	
	// implementing the following methods to reliably receive calls
	// when user clicks "x" and searchBar is not first responder
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if !searchBar.isFirstResponder {
			shouldBeginEditing = false
			delegate?.didClearSearchWithNoFirstResponder()
		}
	}

	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		let returnValue = shouldBeginEditing
		shouldBeginEditing = true
		return returnValue
	}
	
}

extension FeaturedView: UITextFieldDelegate {
	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		delegate?.didClearSearchWithFirstResponder(textField)
		return true
	}
}
