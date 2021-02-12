//
//  DetailAnimator.swift
//  PicSplash
//
//  Created by Marcus on 2/11/21.
//

import UIKit

// this class is handling the view controller transition
// between HomeViewController and DetailViewController

class DetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	// class vars
	
	private static let duration: TimeInterval = 0.25
	
	
	// instance vars
	
	private let presentationType: PresentationType
	private let homeViewController: HomeViewController
	private let detailViewController: DetailViewController
	private let selectedCellImageSnapshot: UIView
	private let cellImageViewRect: CGRect
	
	
	// nested enum to see if which transition we're in
	
	enum PresentationType {
		case present
		case dismiss
		
		func isPresenting() -> Bool {
			self == .present
		}
	}
	
	
	// failable init
		
	// important note: if something “goes wrong”,
	// for example, we can’t prepare all the needed
	// properties (basically the init fails), make
	// sure we return nil. This way the app will use
	// default present/dismiss animation and the user
	// won’t be stuck somewhere in the middle of the transition
	init?(presentationType: PresentationType,
				homeViewController: HomeViewController,
				detailViewController: DetailViewController,
				selectedImageViewSnapshot: UIView) {
		self.presentationType = presentationType
		self.homeViewController = homeViewController
		self.detailViewController = detailViewController
		self.selectedCellImageSnapshot = selectedImageViewSnapshot
		
		guard let window = homeViewController.view.window ?? detailViewController.view.window,
					let selectedCell = homeViewController.selectedCell else { return nil }
		
		// getting the frame of the imageView of the cell relative to the windows frame
		self.cellImageViewRect = selectedCell.displayImageView.convert(selectedCell.displayImageView.bounds, to: window)
	}

	
	// conformance methods
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		Self.duration // not much to do here for this transition
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		// TODO: implement
	}
	
}
