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
	private var selectedCellImageViewSnapshot: UIView
	private let cellImageViewRect: CGRect
	private let cellDisplayLabelRect: CGRect
	
	
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
		
		// getting the frame of the imageView & displayLabel of the cell relative to the windows frame
		self.cellImageViewRect = selectedCell.displayImageView.convert(selectedCell.displayImageView.bounds, to: window)
		self.cellDisplayLabelRect = selectedCell.displayLabel.convert(selectedCell.displayLabel.bounds, to: window)
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
					let cellImageViewSnapshot = selectedCell.displayImageView.snapshotView(afterScreenUpdates: true),
					let cellDisplayLabelSnapshot = selectedCell.displayLabel.snapshotView(afterScreenUpdates: true),
					let scrollingNavViewSnapshot = homeViewController.scrollingNavView.snapshotView(afterScreenUpdates: true) else {
			// report to UIKit that transition did not complete as intended
			transitionContext.completeTransition(false)
			return
		}
		
		// capture isPresenting for easy reference
		let isPresenting = presentationType.isPresenting
		
		// setup backgroundView/fadeView
		let backgroundView: UIView // this view will represent HomeViewController.view
		let fadeView: UIView = UIView(frame: containerView.bounds) // this view will represent DetailViewController.view
		fadeView.backgroundColor = detailViewController.view.backgroundColor
		
		if isPresenting {
			// this is a workaround to the issue that at the moment of taking
			// the selectedCellImageViewSnapshot snapshot, the view is not yet
			// updated so we take the snapshot again. I couldn’t find the proper
			// way to overcome this issue.
			selectedCellImageViewSnapshot = cellImageViewSnapshot
			
			// backgroundView doesn't do much in this case
			// its just a containerView for fadeView
			backgroundView = UIView(frame: containerView.bounds)
			backgroundView.addSubview(fadeView)
			fadeView.alpha = 0.0
		} else {
			// we don't ever expect to get nil in this case
			backgroundView = homeViewController.view.snapshotView(afterScreenUpdates: true) ?? fadeView
			backgroundView.addSubview(fadeView)
		}
		
		// hide otherwise it'll overlap the animation
		toView.alpha = 0.0
		
		// add snapshots/views to containerView
		// we're putting scrollingNavViewSnapshot on top
		// because we always want selectedCellImageViewSnapshot
		// to appear that it's under it although it's really not
		// in the view hierarchy of HomeViewController :)
		[backgroundView, selectedCellImageViewSnapshot, cellDisplayLabelSnapshot, scrollingNavViewSnapshot].forEach { containerView.addSubview($0) }

		// get various views' bounds in windows coordinate space
		let detailVCImageViewRect = detailViewController.detailImageView.convert(detailViewController.detailImageView.bounds, to: window)
		let homeVCscrollingNavRect = homeViewController.scrollingNavView.convert(homeViewController.scrollingNavView.bounds, to: window)
		let cellDisplayLabelRect = selectedCell.displayLabel.convert(selectedCell.displayLabel.bounds, to: window)
		
		// set starting frames on snapshots based on PresentationType
		[selectedCellImageViewSnapshot].forEach { $0.frame = isPresenting ? cellImageViewRect : detailVCImageViewRect }
		
		// set frame (always the same) and alpha on scrollingNavViewSnapshot
		scrollingNavViewSnapshot.frame = homeVCscrollingNavRect
		scrollingNavViewSnapshot.alpha = isPresenting ? 1.0 : 0.0
		
		// set frame (always the same) and alpha on cellDisplayLabelSnapshot
		cellDisplayLabelSnapshot.frame = cellDisplayLabelRect
		cellDisplayLabelSnapshot.alpha = isPresenting ? 1.0 : 0.0
		
		// use keyframes for max animation control
		UIView.animateKeyframes(withDuration: Self.duration,
														delay: 0.0, options: .calculationModeCubic) {
			
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
				// set end frames on snapshots based on PresentationType
				self.selectedCellImageViewSnapshot.frame = isPresenting ? detailVCImageViewRect : self.cellImageViewRect

				// set fadeView alpha based on PresentationType
				fadeView.alpha = isPresenting ? 1.0 : 0.0
			}
			
			// slightly modified duration
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: isPresenting ? 1.0 : 0.7) {
				cellDisplayLabelSnapshot.alpha = isPresenting ? 0.0 : 1.0
				scrollingNavViewSnapshot.alpha = isPresenting ? 0.0 : 1.0
			}
			
		} completion: { _ in
			// perform clean up in here
			
			// remove views from containerView
			self.selectedCellImageViewSnapshot.removeFromSuperview()
			backgroundView.removeFromSuperview()
			scrollingNavViewSnapshot.removeFromSuperview()
			cellDisplayLabelSnapshot.removeFromSuperview()
			
			// show toView
			toView.alpha = 1.0
			
			// notify context that we completed successfully
			transitionContext.completeTransition(true)
		}
	}
	
}
