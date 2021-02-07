//
//  ImageShadowOverlayView.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

// a view's main layer always fills the view's bounds even
// if we update the constraints of said view dynamically -
// as long as the view's constraints are updated correctly

class ImageShadowOverlayView: UIView {
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// capture CAGradientLayer using guard & set colors
		guard let gradientLayer = self.layer as? CAGradientLayer else { return }
		gradientLayer.colors = [
			UIColor.clear.cgColor,
			UIColor.black.cgColor,
		]
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in ImageShadowOverlayView")
	}
	
	// override default layer's class which is CALayer
	// but we want a gradient so we are using CAGradientLayer
	override class var layerClass: AnyClass {
		CAGradientLayer.self
	}
}
