//
//  DownSamplingImageOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/21/21.
//

import UIKit

class DownSamplingImageOperation: Operation {
	let imageUrl: URL
	private let imagePointSize: CGSize
	private let imageScale: CGFloat
	
	var downSampledImage: UIImage?
	
	init(imageUrl: URL, imagePointSize: CGSize, imageScale: CGFloat) {
		self.imageUrl = imageUrl
		self.imagePointSize = imagePointSize
		self.imageScale = imageScale
		super.init()
	}
	
	// https://developer.apple.com/videos/play/wwdc2018/219/ - 11:37
	
	// we're very strict about checking for operation cancellation!!
	
	override func main() {
		let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
		
		guard !self.isCancelled else {
			print(">>>> Cancelling DownSamplingImageOperation <<<<")
			return
		}

		let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, imageSourceOptions)!

		guard !self.isCancelled else {
			print(">>>> Cancelling DownSamplingImageOperation <<<<")
			return
		}

		let maxDimensionsInPixels = max(imagePointSize.width, imagePointSize.height) * imageScale
		let downsampleOptions = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceShouldCacheImmediately: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels
		] as CFDictionary

		guard !self.isCancelled else {
			print(">>>> Cancelling DownSamplingImageOperation <<<<")
			return
		}

		let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
		
		guard !self.isCancelled else {
			print(">>>> Cancelling DownSamplingImageOperation <<<<")
			return
		}

		self.downSampledImage = UIImage(cgImage: downSampledImage)
	}
	
}
