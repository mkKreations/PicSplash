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
		
		// pass the desired alpha component, if you want default, pass nil
		case full(CGFloat?)
		
		// pass the desired start & finish alpha components (respectively), if you want defaults, pass nil
		case base(CGFloat?, CGFloat?)
		
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
		case .full(let alphaValue): // kinda weird using let with an optional but makes sense here
			colors = [
				UIColor.black.withAlphaComponent(alphaValue ?? 0.3).cgColor,
				UIColor.black.withAlphaComponent(alphaValue ?? 0.3).cgColor,
			]
		case .base(let startAlpha, let endAlpha): // kinda weird using let with optionals but makes sense here
			colors = [
				UIColor.black.withAlphaComponent(startAlpha ?? 0.3).cgColor,
				UIColor.black.withAlphaComponent(endAlpha ?? 0.6).cgColor,
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
