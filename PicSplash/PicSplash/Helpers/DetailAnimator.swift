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
	private static let duration: TimeInterval = 0.25

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		Self.duration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
	}
	
}
