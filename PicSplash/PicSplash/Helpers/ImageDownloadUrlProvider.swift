//
//  ImageDownloadUrlProvider.swift
//  PicSplash
//
//  Created by Marcus on 2/16/21.
//

import Foundation

// have your Operation/AsyncOperation subclass implement this
// protocol when you need to pass an image url to be downloaded
// to an instance of ImageDownloadOperation but you do not have
// the image url at the time of creating the ImageDownloadOperation
// instance - meaning that you will be fetching the image url in
// the subclass of Operation/AsyncOperation that you implement this
// protocol within

protocol ImageDownloadUrlProvider: AnyObject {
	var imageUrlString: String? { get }
}
