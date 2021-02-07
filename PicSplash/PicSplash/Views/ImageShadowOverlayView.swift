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
	// enum to handle our various styles
	enum OverlayStyle {
		case full
		case base
	}
	
	
	// instance vars
	private let overlayStyle: OverlayStyle
	
	
	// inits
	init(overlayStyle: OverlayStyle) {
		self.overlayStyle = overlayStyle
		
		super.init(frame: .zero) // use autoLayout
		
		// capture CAGradientLayer using guard & set colors based on overlayStyle
		guard let gradientLayer = self.layer as? CAGradientLayer else { return }
		
		let colors: [CGColor] // OJO: has to be at least two colors
		switch self.overlayStyle {
		case .full:
			colors = [
				UIColor.black.withAlphaComponent(0.3).cgColor,
				UIColor.black.withAlphaComponent(0.3).cgColor,
			]
		case .base:
			colors = [
				UIColor.black.withAlphaComponent(0.3).cgColor,
				UIColor.black.withAlphaComponent(0.6).cgColor,
			]
		}
		
		gradientLayer.colors = colors
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
