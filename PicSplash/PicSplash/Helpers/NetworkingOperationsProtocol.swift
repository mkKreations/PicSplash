//
//  NetworkingOperationsProtocol.swift
//  PicSplash
//
//  Created by Marcus on 2/15/21.
//

import UIKit

// since all our top level network requests
// will be executed within their corresponding
// AsyncOperation subclass, any of those subclasses
// can declare a delegate property of this type
// which the NetworkingManager will conform to so
// each AsyncOperation subclass can pass out any
// information during their operations

protocol NetworkingOperationsProtocol: AnyObject {
	var homeSections: [PhotoSection] { get }
	
	func cacheBlurredImage(_ blurredImage: UIImage, forBlurHash blurHash: String)
	func loadedPhotoSection(_ photoSection: [Photo], forPhotoSectionType photoSectionType: PhotoSectionType)
	func loadedPhotoOfTheDay(_ photoOfTheDay: Photo)
}
