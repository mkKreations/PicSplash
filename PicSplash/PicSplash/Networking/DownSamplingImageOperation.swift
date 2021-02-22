//
//  DownSamplingImageOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/21/21.
//

import UIKit

class DownSamplingImageOperation: Operation {
	// private var to pass in in case that the
	// user passes image url via dependencies
	// I honestly hate force unwrapping this but
	// I'm trying to pick the safest URL to man
	private static let dependencyCheckUrl: URL = URL(string: "https://www.google.com/")!

	private(set) var imageUrl: URL
	private let imagePointSize: CGSize
	private let imageScale: CGFloat
	
	var downSampledImage: UIImage?
	
	// OJO:
	// only use covenience init if you will
	// be passing the URL in via operation
	// dependencies, otherwise, use designated init
	convenience init(imagePointSize: CGSize, imageScale: CGFloat) {
		self.init(imageUrl: DownSamplingImageOperation.dependencyCheckUrl, imagePointSize: imagePointSize, imageScale: imageScale)
	}
	
	init(imageUrl: URL, imagePointSize: CGSize, imageScale: CGFloat) {
		self.imageUrl = imageUrl
		self.imagePointSize = imagePointSize
		self.imageScale = imageScale
		super.init()
	}
	
	// https://developer.apple.com/videos/play/wwdc2018/219/ - 11:37
	// we're very strict about checking for operation cancellation!!
	
	override func main() {
		// check to see if we have any passed in dependencies
		let dependencyImageUrlStringOptional = dependencies.compactMap({ ($0 as? ImageDownloadUrlProvider)?.imageUrlString }).first
		
		// if it passes all checks, assign value to imageUrl
		if imageUrl == Self.dependencyCheckUrl,
			 let dependencyImageUrlString = dependencyImageUrlStringOptional,
			 let dependencyImageUrl = URL(string: dependencyImageUrlString) {
			imageUrl = dependencyImageUrl
		}

		// process to produce UIImage using thumbnail
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
