//
//  DetailViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/11/21.
//

import UIKit

protocol DetailButtonActionsProvider: AnyObject {
	func didPressCloseButton(_ sender: UIButton)
	func didPressShareButton(_ sender: UIButton)
}

class DetailViewController: UIViewController {
	// internal vars
	let detailImageView: UIImageView = UIImageView(frame: .zero) // expose to public for view controller transition
	private var imagePlaceholder: ImagePlaceholder
	private let closeButton: UIButton = UIButton(type: .system)
	private let titleLabel: UILabel = UILabel(frame: .zero)
	private let shareButton: UIButton = UIButton(type: .system)
	private let navStackView: UIStackView = UIStackView(frame: .zero)
	private var navStackViewTopConstraint: NSLayoutConstraint?
	weak var delegate: DetailButtonActionsProvider?
	
	
	// MARK: inits
	
	init(imagePlaceholder: ImagePlaceholder) {
		self.imagePlaceholder = imagePlaceholder
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("Crash in DetailViewController")
	}
	
	
	// MARK: view life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .picSplashBlack
		
		configureSubviews()
		constrainSubviews()
	}
	
	
	// MARK: helpers
	
	private func configureSubviews() {
		detailImageView.translatesAutoresizingMaskIntoConstraints = false
		detailImageView.backgroundColor = imagePlaceholder.placeholderColor
		detailImageView.contentMode = .scaleAspectFit
		view.addSubview(detailImageView)
		
		navStackView.translatesAutoresizingMaskIntoConstraints = false
		[closeButton, titleLabel, shareButton].forEach { navStackView.addArrangedSubview($0) }
		navStackView.axis = .horizontal
		navStackView.distribution = .fill
		navStackView.spacing = 10.0
		view.addSubview(navStackView)
		
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
		closeButton.tintColor = .white
		closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
		closeButton.setContentHuggingPriority(.required, for: .horizontal)

		shareButton.translatesAutoresizingMaskIntoConstraints = false
		shareButton.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
		shareButton.tintColor = .white
		shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
		shareButton.setContentHuggingPriority(.required, for: .horizontal)

		titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
		titleLabel.textColor = .white
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .center
		titleLabel.text = "\(imagePlaceholder.height)"
	}
	
	private func constrainSubviews() {
		detailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		detailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		detailImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		detailImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		// low priority on this constraint to maintain image in view
		let imageHeightConstraint = detailImageView.heightAnchor.constraint(equalToConstant: CGFloat(imagePlaceholder.height))
		imageHeightConstraint.priority = UILayoutPriority(500)
		imageHeightConstraint.isActive = true
		
		// if imageView is too tall - respect top & bottom constraints
		let imageTopConstraint = detailImageView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 40.0)
		imageTopConstraint.priority = UILayoutPriority(999)
		imageTopConstraint.isActive = true

		let imageBottomConstraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: detailImageView.bottomAnchor, constant: 40.0)
		imageBottomConstraint.priority = UILayoutPriority(999)
		imageBottomConstraint.isActive = true
		
		navStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
		navStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
		navStackViewTopConstraint = navStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0)
		navStackViewTopConstraint?.isActive = true
		
		closeButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true

		shareButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
	}
	
	@objc private func closeButtonPressed(_ sender: UIButton) {
		dismiss(animated: true) {
			self.delegate?.didPressCloseButton(sender)
		}
	}
	
	@objc private func shareButtonPressed(_ sender: UIButton) {
		delegate?.didPressShareButton(sender)
	}
	
}
