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
	// class vars
	static private let tapFadeAnimationDuration: TimeInterval = 0.5
	
	// internal vars
	let detailImageView: UIImageView = UIImageView(frame: .zero) // expose to public for view controller transition
	private var imagePlaceholder: ImagePlaceholder
	let closeButton: UIButton = UIButton(type: .system)
	let titleLabel: UILabel = UILabel(frame: .zero)
	let shareButton: UIButton = UIButton(type: .system)
	let infoButton: UIButton = UIButton(type: .custom)
	let likeButton: DetailActionButton = DetailActionButton(detailAction: .like)
	let addButton: DetailActionButton = DetailActionButton(detailAction: .add)
	let downloadButton: DetailActionButton = DetailActionButton(detailAction: .download)
	private let actionButtonsStackView: UIStackView = UIStackView(frame: .zero)
	private let navStackView: UIStackView = UIStackView(frame: .zero)
	private var navStackViewTopConstraint: NSLayoutConstraint?
	weak var delegate: DetailButtonActionsProvider?
	private var subviewsShowing: Bool = true // always true by default
	
	
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
		
		// add tap gesture
		let tapGest = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		tapGest.numberOfTapsRequired = 1
		view.addGestureRecognizer(tapGest)
		
		configureSubviews()
		constrainSubviews()
	}
	
	
	
	// MARK: tap gest/animation
	
	@objc private func handleTap(_ tapGesture: UITapGestureRecognizer) {
		if tapGesture.state == .ended {
			animateSubviewsToShowHideImage()
		}
	}
	
	private func animateSubviewsToShowHideImage() {
		// disable view interactions for animation duration
		view.isUserInteractionEnabled = false

		// set initial states
		infoButton.alpha = subviewsShowing ? 1.0 : 0.0
		actionButtonsStackView.alpha = subviewsShowing ? 1.0 : 0.0
		
		// animate to end states
		UIView.animate(withDuration: Self.tapFadeAnimationDuration,
									 delay: 0.0,
									 options: .curveEaseInOut) {
			// set end states - alphas
			self.infoButton.alpha = self.subviewsShowing ? 0.0 : 1.0
			self.actionButtonsStackView.alpha = self.subviewsShowing ? 0.0 : 1.0
		} completion: { _ in
			// flip subviewsShowing
			self.subviewsShowing = !self.subviewsShowing
			
			// set any properties based on if subviews are showing
			self.infoButton.isUserInteractionEnabled = self.subviewsShowing
			self.actionButtonsStackView.isUserInteractionEnabled = self.subviewsShowing
			
			// enable view interactions once animation
			// and setting of values is completed
			self.view.isUserInteractionEnabled = true
		}
	}
	
	
	
	// MARK: view/subview stuff
	
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
		
		infoButton.translatesAutoresizingMaskIntoConstraints = false
		infoButton.setBackgroundImage(UIImage(systemName: "info.circle"), for: .normal)
		infoButton.tintColor = .white
		view.addSubview(infoButton)
		
		actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
		[likeButton, addButton, downloadButton].forEach {
			$0.delegate = self
			actionButtonsStackView.addArrangedSubview($0)
		}
		actionButtonsStackView.axis = .vertical
		actionButtonsStackView.spacing = 16.0
		view.addSubview(actionButtonsStackView)
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
		let imageTopConstraint = detailImageView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 24.0)
		imageTopConstraint.priority = UILayoutPriority(999)
		imageTopConstraint.isActive = true

		let imageBottomConstraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: detailImageView.bottomAnchor, constant: 24.0)
		imageBottomConstraint.priority = UILayoutPriority(999)
		imageBottomConstraint.isActive = true
		
		navStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
		navStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
		navStackViewTopConstraint = navStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0)
		navStackViewTopConstraint?.isActive = true
		
		closeButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true

		shareButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
		
		infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
		infoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0).isActive = true
		infoButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
		infoButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
		
		actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
		actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0).isActive = true
	}
	
	
	
	// MARK: button actions
	
	@objc private func closeButtonPressed(_ sender: UIButton) {
		dismiss(animated: true) {
			self.delegate?.didPressCloseButton(sender)
		}
	}
	
	@objc private func shareButtonPressed(_ sender: UIButton) {
		delegate?.didPressShareButton(sender)
	}
	
}



// MARK: DetailActionButtonsProvider conformance

extension DetailViewController: DetailActionButtonsProvider {
	func didPressDetailActionButton(_ detailAction: DetailAction) {
		// TODO: implement
		print(detailAction)
	}
}
