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
	private(set) var photoOfTheDay: Photo?
	private(set) var homeImagesSections: [PhotoSection] = {
	var sections: [PhotoSection] = []
		// instantiate PhotoSection from our enum
		PhotoSectionType.allCases.forEach { type in
			sections.append(PhotoSection(title: type.sectionTitle, type: type, items: []))
		}
		return sections
	}()
	
	
	
	// MARK: helpers

	// we're not cancelling operations - instead we're keeping track
	// of all current operations and managing their queue priorities
	func lowerQueuePriority(forImageUrlString imageUrlString: String) {
		// ensure we have the operation running in the queue
		guard let operations = (imageDownloadQueue.operations as? [ImageDownloadOperation])?
						.filter({ $0.imageUrl.absoluteString == imageUrlString && $0.isExecuting == true && $0.isFinished == false }),
					let currentOperation = operations.first else { return }
		print("REDUCE THE QUEUE PRIORITY OF OPERATION \(imageUrlString)")
		currentOperation.queuePriority = .low // if so, lower its priority
	}

	func cachedBlurredImage(forBlurHashString blurHash: String) -> UIImage? {
		imageDownloadCache.object(forKey: NSString(string: blurHash))
	}
	
	func cachedImage(forImageUrlString imageUrlString: String) -> UIImage? {
		imageDownloadCache.object(forKey: NSString(string: imageUrlString))
	}
		
	private func constructInitialCollectionViewDataLoadUrl() -> (url: URL?, error: NetworkingError?) {
		// construct urlString
		var requestUrlString: String = Self.baseUrlString
		requestUrlString.append(Self.homeImagesListPath)
		
		// ensure we have valid Url
		guard var baseComponent: URLComponents = URLComponents(string: requestUrlString) else {
			return (nil, .invalidUrl)
		}
		
		let queryItems: [URLQueryItem] = [
			URLQueryItem(name: "client_id", value: Secrets.API_KEY),
			URLQueryItem(name: "page", value: "1"),
			URLQueryItem(name: "per_page", value: "30"),
		]
		baseComponent.queryItems = queryItems
		
		// ensure we have valid Url
		guard let requestUrl = baseComponent.url else {
			return (nil, .invalidUrl)
		}
		
		return (requestUrl, nil)
	}
	
	private func constructPhotoOfTheDayUrl() -> (url: URL?, error: NetworkingError?) {
		// construct urlString
		var requestString: String = Self.baseUrlString
		requestString.append("/photos/random")
		
		// ensure we have valid Url
		guard var baseComponent: URLComponents = URLComponents(string: requestString) else {
			return (nil, .invalidUrl)
		}
		
		let queryItems: [URLQueryItem] = [
			URLQueryItem(name: "client_id", value: Secrets.API_KEY),
			URLQueryItem(name: "featured", value: nil),
			URLQueryItem(name: "orientation", value: "landscape"),
		]
		baseComponent.queryItems = queryItems
		
		// ensure we have valid Url
		guard let requestUrl = baseComponent.url else {
			return (nil, .invalidUrl)
		}
		
		return (requestUrl, nil)
	}
	
	private func constructExploreCollectionsFetchUrl() -> (url: URL?, error: NetworkingError?) {
		// construct urlString
		var requestString: String = Self.baseUrlString
		requestString.append("/collections")
		
		// ensure we have valid Url
		guard var baseComponent: URLComponents = URLComponents(string: requestString) else {
			return (nil, .invalidUrl)
		}
		
		let queryItems: [URLQueryItem] = [
			URLQueryItem(name: "client_id", value: Secrets.API_KEY),
			URLQueryItem(name: "page", value: "1"),
			URLQueryItem(name: "per_page", value: "30"),
		]
		baseComponent.queryItems = queryItems
		
		// ensure we have valid Url
		guard let requestUrl = baseComponent.url else {
			return (nil, .invalidUrl)
		}
		
		return (requestUrl, nil)
	}
	
	
	
	// MARK: asynchronous tasks
	
	func downloadHomeInitialData(withCompletion completion: @escaping (NetworkingError?) -> ()) {
		// construct all urls necessary to load initial data for home
		let initialCollectionViewDataLoadUrlTuple = constructInitialCollectionViewDataLoadUrl()
		let photoOfTheDayUrlTuple = constructPhotoOfTheDayUrl()
		let exploreCollectionsFetchUrlTuple = constructExploreCollectionsFetchUrl()
		
		// make sure we got valid url - InitialCollectionViewDataLoad
		guard let initialCollectionViewDataLoadUrl = initialCollectionViewDataLoadUrlTuple.url else {
			completion(initialCollectionViewDataLoadUrlTuple.error)
			return
		}
		
		// make sure we got valid url - PhotoOfTheDay
		guard let photoOfTheDayUrl = photoOfTheDayUrlTuple.url else {
			completion(photoOfTheDayUrlTuple.error)
			return
		}
		
		// make sure we got valid url - ExploreCollections
		guard let exploreCollectionsFetchUrl = exploreCollectionsFetchUrlTuple.url else {
			completion(exploreCollectionsFetchUrlTuple.error)
			return
		}

		print("InitialCollectionViewDataLoadUrl URL: \(initialCollectionViewDataLoadUrl)")
		print("PhotoOfTheDay URL: \(photoOfTheDayUrl)")
		print("ExploreCollections URL: \(exploreCollectionsFetchUrl)")

		// create and add each Operation required
		// to load all home data for initial load
		
		// InitialCollectionViewDataLoad
		let initialCollectionViewDataLoadOperation = InitialCollectionViewDataLoadOperation(initialDataToLoadUrl: initialCollectionViewDataLoadUrl)
		initialCollectionViewDataLoadOperation.delegate = self
		self.imageDownloadQueue.addOperation(initialCollectionViewDataLoadOperation)
		
		// PhotoOfTheDay
		
		// this operation fetches the Photo of the Day object
		let photoOfTheDayOperation = PhotoOfTheDayOperation(photoOfTheDayUrl: photoOfTheDayUrl)
		photoOfTheDayOperation.delegate = self
		
		// this operation fetches & caches the image for the Photo of the Day object
		let photoOfTheDayImageDownloadOperation = ImageDownloadOperation()
		photoOfTheDayImageDownloadOperation.addDependency(photoOfTheDayOperation) // image download waits until object fetch finishes before executing
		photoOfTheDayImageDownloadOperation.imageHandler = { image, error in
			if let error = error {
				print("Photo of the day image download error: \(error)")
				return
			}
			
			guard let image = image else { return }
			
			print("CACHING PHOTO OF THE DAY IMAGE")
			
			// cache the image using the url as the key
			self.imageDownloadCache.setObject(image, forKey: NSString(string: photoOfTheDayImageDownloadOperation.imageUrl.absoluteString))
		}

		// add PhotoOfTheDay operations
		self.imageDownloadQueue.addOperation(photoOfTheDayOperation)
		self.imageDownloadQueue.addOperation(photoOfTheDayImageDownloadOperation)
		
		// once all data fetching Operations have been added to queue
		// add this BarrierBlock to the queue which requires
		// that all previously added tasks must be completed
		// in order for this task to be executed - we're simply
		// handing control back over to the UI
		self.imageDownloadQueue.addBarrierBlock {
			completion(nil)
		}
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
	
	func loadedPhotoSection(_ homeImages: [HomeImageProtocol], forPhotoSectionType photoSectionType: PhotoSectionType) {
		var section = homeImagesSections[photoSectionType.rawValue]
		section.items = homeImages
		homeImagesSections[photoSectionType.rawValue] = section
	}
	
	func loadedPhotoOfTheDay(_ photoOfTheDay: Photo) {
		self.photoOfTheDay = photoOfTheDay // only need to capture reference
	}
}
