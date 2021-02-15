//
//  BlurHashOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/15/21.
//

import UIKit

// creating an Operation for this task
// because it's computationally expensive
// and lags when called on main thread

class BlurHashOperation: Operation {
	let blurHash: String
	
	var blurredImage: UIImage?
	
	init(blurHash: String) {
		self.blurHash = blurHash
		super.init()
	}
	
	override func main() {
		// using CGSize values recommended by documentations
		blurredImage = UIImage(blurHash: blurHash,
													 size: CGSize(width: 32.0, height: 32.0))
	}
}
