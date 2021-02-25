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
	private static var buttonTopMargin: CGFloat {
		// keyWindow is "deprecated" but as long as we know that
		// we're not supporting iPad - we're fine
		
		// get the value from the window since accessing the
		// safeAreaInset of the view in viewDidLoad returns 0
		let safeAreaInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
		return safeAreaInset
	}

	
	// instance vars
	private let vertStackView: UIStackView = UIStackView(frame: .zero)
	private let displayLabel: UILabel = UILabel(frame: .zero)
	private let searchBar: UISearchBar = UISearchBar(frame: .zero)
	private let displayImageView: UIImageView = UIImageView(frame: .zero)
	private let gradientOverlayView: ImageShadowOverlayView = ImageShadowOverlayView(overlayStyle: .full(nil))
	private let loginButton: UIButton = UIButton(type: .system)
	private let menuButton: UIButton = UIButton(type: .system)
	private var loginButtonTopConstraint: NSLayoutConstraint?
	private var menuButtonTopConstraint: NSLayoutConstraint?
	weak var delegate: FeaturedViewButtonsProvider?
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
		menuButton.alpha = scrollDelta
		loginButton.alpha = scrollDelta
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
	
	func updateConstraintsForSafeAreaEdgeInsets() {
		menuButtonTopConstraint?.constant = Self.buttonTopMargin
		loginButtonTopConstraint?.constant = Self.buttonTopMargin
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
				
		menuButton.translatesAutoresizingMaskIntoConstraints = false
		menuButton.setImage(UIImage(named: "PicSplash Icon"), for: .normal)
		menuButton.imageView?.contentMode = .scaleAspectFit // maintain aspect ratio
		menuButton.tintColor = .white
		menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
		menuButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
		addSubview(menuButton)

		loginButton.translatesAutoresizingMaskIntoConstraints = false
		let loginButtonSymbolConfig = UIImage.SymbolConfiguration(pointSize: 22.0)
		loginButton.setImage(UIImage(systemName: "person.circle", withConfiguration: loginButtonSymbolConfig), for: .normal)
		loginButton.tintColor = .white
		loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
		addSubview(loginButton)

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
		searchBar.searchTextField.textColor = .white
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
		
		menuButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
		menuButton.widthAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		menuButton.heightAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		menuButtonTopConstraint = menuButton.topAnchor.constraint(equalTo: topAnchor, constant: Self.buttonTopMargin)
		menuButtonTopConstraint?.isActive = true

		loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
		loginButton.widthAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		loginButton.heightAnchor.constraint(equalToConstant: Self.buttonDimension).isActive = true
		loginButtonTopConstraint = loginButton.topAnchor.constraint(equalTo: topAnchor, constant: Self.buttonTopMargin)
		loginButtonTopConstraint?.isActive = true

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
