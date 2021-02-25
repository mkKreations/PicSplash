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
	static private var navStackViewTopMargin: CGFloat {
		// keyWindow is "deprecated" but as long as we know that
		// we're not supporting iPad - we're fine
		
		// get the value from the window since accessing the
		// safeAreaInset of the view in viewDidLoad returns 0
		
		// we're safe here in DetailViewController because views
		// have been loaded into the frame buffer at least once,
		// but if no views have been loaded into the frame buffer,
		// then safeAreaEdgeInsets will always return 0
		let safeAreaInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
		return safeAreaInset + 10.0
	}
	
	// internal vars
	let detailImageView: UIImageView = UIImageView(frame: .zero) // expose to public for view controller transition
	private let detailPhoto: Photo
	private let calculatedDetailPhotoHeight: CGFloat
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
	
	init(photo: Photo, withCalculatedHeight height: CGFloat) {
		self.detailPhoto = photo
		self.calculatedDetailPhotoHeight = height
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

		// set initial states - alphas
		infoButton.alpha = subviewsShowing ? 1.0 : 0.0
		actionButtonsStackView.alpha = subviewsShowing ? 1.0 : 0.0
		navStackView.alpha = subviewsShowing ? 1.0 : 0.0
		
		// set initial states - constraints
		navStackViewTopConstraint?.constant = subviewsShowing ? -navStackView.frame.height : Self.navStackViewTopMargin
		
		// add key frame animations
		UIView.animateKeyframes(withDuration: Self.tapFadeAnimationDuration,
														delay: 0.0, options: .calculationModeCubic) {
			
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
				// set end states - alphas
				self.infoButton.alpha = self.subviewsShowing ? 0.0 : 1.0
				self.actionButtonsStackView.alpha = self.subviewsShowing ? 0.0 : 1.0

				// set end states - constraints
				self.view.layoutIfNeeded()
			}
			
			UIView.addKeyframe(withRelativeStartTime: self.subviewsShowing ? 0.0 : 0.2,
												 relativeDuration: self.subviewsShowing ? 0.6 : 1.0) {
				// set end states - alphas
				self.navStackView.alpha = self.subviewsShowing ? 0.0 : 1.0
			}
			
		} completion: { _ in
			// flip subviewsShowing
			self.subviewsShowing = !self.subviewsShowing
			
			// set any properties based on if subviews are showing
			self.infoButton.isUserInteractionEnabled = self.subviewsShowing
			self.actionButtonsStackView.isUserInteractionEnabled = self.subviewsShowing
			self.navStackView.isUserInteractionEnabled = self.subviewsShowing
			
			// enable view interactions once animation
			// and setting of values is completed
			self.view.isUserInteractionEnabled = true
		}
		
	}
	
	
	
	// MARK: view/subview stuff
	
	private func configureSubviews() {
		detailImageView.translatesAutoresizingMaskIntoConstraints = false
		detailImageView.image = NetworkingManager.shared.cachedImage(forImageUrlString: detailPhoto.imageUrl)
		detailImageView.contentMode = .scaleAspectFill
		detailImageView.clipsToBounds = true
		view.addSubview(detailImageView)
		
		navStackView.translatesAutoresizingMaskIntoConstraints = false
		[closeButton, titleLabel, shareButton].forEach { navStackView.addArrangedSubview($0) }
		navStackView.axis = .horizontal
		navStackView.distribution = .fill
		navStackView.spacing = 10.0
		view.addSubview(navStackView)
		
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.setImage(UIImage(systemName: "xmark"), for: .normal) // set foreground image
		closeButton.tintColor = .white
		closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
		closeButton.setContentHuggingPriority(.required, for: .horizontal)

		shareButton.translatesAutoresizingMaskIntoConstraints = false
		shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal) // set foreground image
		shareButton.tintColor = .white
		shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
		shareButton.setContentHuggingPriority(.required, for: .horizontal)

		titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
		titleLabel.textColor = .white
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .center
		titleLabel.text = detailPhoto.author
		
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
		detailImageView.heightAnchor.constraint(equalToConstant: CGFloat(calculatedDetailPhotoHeight)).isActive = true
		
		navStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
		navStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
		navStackViewTopConstraint = navStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: Self.navStackViewTopMargin)
		navStackViewTopConstraint?.isActive = true
		
		closeButton.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 27.5).isActive = true

		shareButton.widthAnchor.constraint(equalToConstant: 27.0).isActive = true
		shareButton.heightAnchor.constraint(equalToConstant: 27.5).isActive = true

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
	
	
	
	// MARK: overrides
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}

}



// MARK: DetailActionButtonsProvider conformance

extension DetailViewController: DetailActionButtonsProvider {
	func didPressDetailActionButton(_ detailAction: DetailAction) {
		// TODO: implement
		print(detailAction)
	}
}
