//
//  DownSamplingImageOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/21/21.
//

import UIKit

class DownSamplingImageOperation: Operation {
	private let imageUrl: URL
	private let imagePointSize: CGSize
	private let imageScale: CGFloat
	
	var downSampledImage: UIImage?
	
	init(imageUrl: URL, imagePointSize: CGSize, imageScale: CGFloat) {
		self.imageUrl = imageUrl
		self.imagePointSize = imagePointSize
		self.imageScale = imageScale
		super.init()
	}
	
	override func main() {
		self.downSampledImage = downsample(imageAt: imageUrl, to: imagePointSize, scale: imageScale)
	}
	
	// https://developer.apple.com/videos/play/wwdc2018/219/ - 11:37
	func downsample(imageAt imageUrl: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
		let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
		let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, imageSourceOptions)!
		
		let maxDimensionsInPixels = max(pointSize.width, pointSize.height) * scale
		let downsampleOptions = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceShouldCacheImmediately: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceThumbnailMaxPixelSize: maxDimensionsInPixels
		] as CFDictionary
		
		let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
		return UIImage(cgImage: downSampledImage)
	}
}
