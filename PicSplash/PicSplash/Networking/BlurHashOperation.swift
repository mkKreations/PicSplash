//
//  BlurHashOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/15/21.
//

import UIKit

class BlurHashOperation: Operation {
	private let blurHash: String
	
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
