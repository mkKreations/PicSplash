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
	
	private static let duration: TimeInterval = 1.25
	
	
	// instance vars
	
	private let presentationType: PresentationType
	private let homeViewController: HomeViewController
	private let detailViewController: DetailViewController
	private var selectedCellImageViewSnapshot: UIView
	private let cellImageViewRect: CGRect
	
	
	// nested enum to see if which transition we're in
	
	enum PresentationType {
		case present
		case dismiss
		
		var isPresenting: Bool {
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
		self.selectedCellImageViewSnapshot = selectedImageViewSnapshot
		
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
		// get containerView from context for easy reference
		let containerView = transitionContext.containerView
		
		guard let toView = detailViewController.view else {
			// report to UIKit that transition did not complete as intended
			transitionContext.completeTransition(false)
			return
		}
		
		containerView.addSubview(toView) // add toView to containerView first
		
		// unpack all necessary vars
		guard let selectedCell = homeViewController.selectedCell,
					let window = homeViewController.view.window ?? detailViewController.view.window,
					let cellImageSnapshot = selectedCell.displayImageView.snapshotView(afterScreenUpdates: true) else {
			// report to UIKit that transition did not complete as intended
			transitionContext.completeTransition(false)
			return
		}
		
		// capture isPresenting for easy reference
		let isPresenting = presentationType.isPresenting
		
		if isPresenting {
			// this is a workaround to the issue that at the moment of taking
			// the selectedCellImageViewSnapshot snapshot, the view is not yet
			// updated so we take the snapshot again. I couldn’t find the proper
			// way to overcome this issue.
			selectedCellImageViewSnapshot = cellImageSnapshot
		}
		
		// add snapshots to containerView
		[selectedCellImageViewSnapshot].forEach { containerView.addSubview($0) }
		
		// get DetailVC image bounds in windows coordinate space
		let detailVCImageViewRect = detailViewController.detailImageView.convert(detailViewController.detailImageView.bounds, to: window)
		
		// set starting frames on snapshots based on PresentationType
		[selectedCellImageViewSnapshot].forEach { $0.frame = isPresenting ? cellImageViewRect : detailVCImageViewRect }
		
		// use keyframes for max animation control
		UIView.animateKeyframes(withDuration: Self.duration,
														delay: 0.0, options: .calculationModeCubic) {
			
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
				// set end frames on snapshots based on PresentationType
				self.selectedCellImageViewSnapshot.frame = isPresenting ? detailVCImageViewRect : self.cellImageViewRect
			}
			
		} completion: { _ in
			// perform clean up in here
			
			// remove cellImageSnapshot
			self.selectedCellImageViewSnapshot.removeFromSuperview()
			
			// notify context that we completed successfully
			transitionContext.completeTransition(true)
		}
	}
	
}
