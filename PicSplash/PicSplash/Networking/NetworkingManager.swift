//
//  NetworkingManager.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import UIKit

// enum to cover our error cases

enum NetworkingError: Error {
	case serverError(Error)
	case invalidUrl
	case invalidResponse
	case failedDeserialization
	case failedDataProcessing
}

// typealias to help pass around completions
typealias ImageDownloadHandler = (_ image: UIImage?, _ error: NetworkingError?) -> ()

// singleton to handle our networking
// not needed to be thread-safe atm

class NetworkingManager {
	
	// class vars
	static private let baseUrlString: String = "https://api.unsplash.com"
	static private let homeImagesListPath: String = "/photos"
	static private var clientIDPath: String {
		"/?client_id=\(Secrets.API_KEY)"
	}
	
	
	// singleton
	private init() {}
	static let shared: NetworkingManager = NetworkingManager()
	
	
	// MARK: instance vars
	
	private var completionHandler: ImageDownloadHandler? // only to store references to any local completion blocks
	private let imageDownloadQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	private let imageDownloadCache: NSCache<NSString, UIImage> = NSCache()
	private(set) var homeImagesSections: [PhotoSection] = {
	var sections: [PhotoSection] = []
		// instantiate PhotoSection from our enum
		PhotoSectionType.allCases.forEach { type in
			sections.append(PhotoSection(title: type.sectionTitle, type: type, items: []))
		}
		return sections
	}()
	
	
	
	// MARK: asynchronous tasks
	
	func downloadHomeInitialData(withCompletion completion: @escaping (NetworkingError?) -> ()) {
		// construct urlString
		var requestUrlString: String = Self.baseUrlString
		requestUrlString.append(Self.homeImagesListPath)
		requestUrlString.append(Self.clientIDPath)
		
		// ensure we have valid Url
		guard let requestUrl = URL(string: requestUrlString) else {
			completion(.invalidUrl)
			return
		}

		print("OUR URL: \(requestUrl)")
		
		// create and add each Operation required
		// to load all home data for initial load
		let initialCollectionViewDataLoadOperation = InitialCollectionViewDataLoadOperation(initialDataToLoadUrl: requestUrl)
		initialCollectionViewDataLoadOperation.delegate = self
		self.imageDownloadQueue.addOperation(initialCollectionViewDataLoadOperation)
		
		// once all data fetching Operations have been added to queue
		// add this BarrierBlock to the queue which requires
		// that all previously added tasks must be completed
		// in order for this task to be executed - we're
		// simply handing control back off to the UI
		self.imageDownloadQueue.addBarrierBlock {
			completion(nil)
		}
	}
	
	func blurredImage(forBlurHashString blurHash: String) -> UIImage? {
		imageDownloadCache.object(forKey: NSString(string: blurHash))
	}
		
	func downloadImage(forImageUrlString imageUrlString: String, withCompletion completion: ((UIImage?, NetworkingError?) -> Void)?) {
		guard let imageUrl = URL(string: imageUrlString) else {
			completion?(nil, NetworkingError.invalidUrl)
			return
		}
	
		// capture local completion
		self.completionHandler = completion
		
		if let cachedImage = imageDownloadCache.object(forKey: NSString(string: imageUrlString)) {
			print("RETURNING CACHED IMAGE")
			self.completionHandler?(cachedImage, nil)
		} else {
			// first see if the operation is currently running on
			// imageDownloadQueue if so - raise its priority to top level
			if let operations = (imageDownloadQueue.operations as? [ImageDownloadOperation])?
						.filter({ $0.imageUrl.absoluteString == imageUrlString && $0.isExecuting == true && $0.isFinished == false }),
				 let currentOperation = operations.first {
				
				currentOperation.queuePriority = .veryHigh
				print("IMAGE OPERATION CURRENTLY RUNNING")
				
			} else {
				let imageDownloadOperation = ImageDownloadOperation(url: imageUrl)
				imageDownloadOperation.queuePriority = .high
				imageDownloadOperation.imageHandler = { image, error in
					if let error = error {
						self.completionHandler?(nil, error)
						return
					}
					
					guard let image = image else { return }
					
					print("CACHING IMAGE")
					
					// cache the image using the url as the key
					self.imageDownloadCache.setObject(image, forKey: NSString(string: imageUrlString))
					
					self.completionHandler?(image, error)
				}
				// add to image download queue
				imageDownloadQueue.addOperation(imageDownloadOperation)
			}
		}
	}
	
}



// MARK: NetworkingOperationsProtocol conformance

extension NetworkingManager: NetworkingOperationsProtocol {
	var homeSections: [PhotoSection] {
		homeImagesSections
	}
	
	func cacheBlurredImage(_ blurredImage: UIImage, forBlurHash blurHash: String) {
		// cache the image using the blur hash as the key
		self.imageDownloadCache.setObject(blurredImage, forKey: NSString(string: blurHash))
	}
	
	func loadedPhotoSection(_ photoSection: [Photo], forPhotoSectionType photoSectionType: PhotoSectionType) {
		var section = homeImagesSections[photoSectionType.rawValue]
		section.items = photoSection
		homeImagesSections[photoSectionType.rawValue] = section
	}
}
