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


// singleton to handle our networking
// not needed to be thread-safe atm

class NetworkingManager {
	
	// class vars
	static private let baseUrlString: String = "https://api.unsplash.com"
	static private let downsampleImageQueueId: String = UUID().uuidString
	
	
	// singleton
	private init() {}
	static let shared: NetworkingManager = NetworkingManager()
	
	
	// MARK: instance vars
	
	private let imageDownloadQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	private let searchQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	private let imageDownsampleQueue: OperationQueue = {
		// the serial dispatch queue to run our operations on
		let serialDispatchQueue = DispatchQueue(label: NetworkingManager.downsampleImageQueueId, qos: .userInteractive)
		
		let operationQueue = OperationQueue()
		operationQueue.underlyingQueue = serialDispatchQueue
		operationQueue.qualityOfService = .userInteractive

		return operationQueue
	}()
	private let imageDownloadCache: NSCache<NSString, UIImage> = NSCache()
	private(set) var searchResults: (results: [Photo], searchTerm: String) = ([], "")
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
	
	func search(withSearchTerm searchTerm: String, withCompletion completion: @escaping ([Photo], String, NetworkingError?) -> ()) {
		// check if search is empty
		if searchTerm.isEmpty {
			completion([], "", nil) // empty results for empty search
			return
		}
		
		// attempt to construct url
		let searchUrlTuple = constructSearchUrl(withSearchTerm: searchTerm)

		// get url
		guard let searchUrl = searchUrlTuple.url else {
			completion([], "", searchUrlTuple.error)
			return
		}
		
		// create search operation
		let searchOperation = SearchOperation(requestUrl: searchUrl, searchTerm: searchTerm)
		searchOperation.delegate = self
		searchOperation.queuePriority = .veryHigh
		searchQueue.addOperation(searchOperation) // adding to our searchQueue
		
		// adding barrier block task requires
		// this operation to wait until all
		// previous operations have completed
		searchQueue.addBarrierBlock { [weak self] in
			guard let self = self else { return }
			
			completion(self.searchResults.results, self.searchResults.searchTerm, nil)
		}
	}
		
	private func constructNewSectionFetchUrl() -> (url: URL?, error: NetworkingError?) {
		// construct urlString
		var requestUrlString: String = Self.baseUrlString
		requestUrlString.append("/photos")
		
		// ensure we have valid Url
		guard var baseComponent: URLComponents = URLComponents(string: requestUrlString) else {
			return (nil, .invalidUrl)
		}
		
		// nothing to pass here because
		// we know we'll have value
		guard let randomPageValue = (1...50).randomElement() else { return (nil, nil) }
		
		let queryItems: [URLQueryItem] = [
			URLQueryItem(name: "client_id", value: Secrets.API_KEY),
			URLQueryItem(name: "page", value: String(randomPageValue)),
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
		
		// nothing to pass here because
		// we know we'll have value, we're
		// doing this to simulate "random" data
		guard let randomPageValue = (1...40).randomElement() else { return (nil, nil) }
		
		let queryItems: [URLQueryItem] = [
			URLQueryItem(name: "client_id", value: Secrets.API_KEY),
			URLQueryItem(name: "page", value: String(randomPageValue)),
			URLQueryItem(name: "per_page", value: "30"),
		]
		baseComponent.queryItems = queryItems
		
		// ensure we have valid Url
		guard let requestUrl = baseComponent.url else {
			return (nil, .invalidUrl)
		}
		
		return (requestUrl, nil)
	}
	
	private func constructSearchUrl(withSearchTerm searchTerm: String) -> (url: URL?, error: NetworkingError?) {
		// construct urlString
		var requestString: String = Self.baseUrlString
		requestString.append("/search/photos")
		
		// ensure we have valid Url
		guard var baseComponent: URLComponents = URLComponents(string: requestString) else {
			return (nil, .invalidUrl)
		}

		// construct parameters
		let queryItems: [URLQueryItem] = [
			URLQueryItem(name: "client_id", value: Secrets.API_KEY),
			URLQueryItem(name: "query", value: searchTerm),
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
		let newSectionFetchUrlTuple = constructNewSectionFetchUrl()
		let photoOfTheDayUrlTuple = constructPhotoOfTheDayUrl()
		let exploreCollectionsFetchUrlTuple = constructExploreCollectionsFetchUrl()
		
		// make sure we got valid url - InitialCollectionViewDataLoad
		guard let newSectionFetchUrl = newSectionFetchUrlTuple.url else {
			completion(newSectionFetchUrlTuple.error)
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

		print("NewSection URL: \(newSectionFetchUrl)")
		print("PhotoOfTheDay URL: \(photoOfTheDayUrl)")
		print("ExploreCollections URL: \(exploreCollectionsFetchUrl)")

		// create and add each Operation required
		// to load all home data for initial load
		
		// NewSectionOperation
		let newSectionOperation = NewSectionOperation(initialDataToLoadUrl: newSectionFetchUrl)
		newSectionOperation.delegate = self
		self.imageDownloadQueue.addOperation(newSectionOperation)
		
		// PhotoOfTheDay - 2 separate operations
		
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
		
		// ExploreCollections
		let exploreCollectionsOperation = ExploreCollectionsOperation(url: exploreCollectionsFetchUrl)
		exploreCollectionsOperation.delegate = self
		self.imageDownloadQueue.addOperation(exploreCollectionsOperation)
		
		// once all data fetching Operations have been added to queue
		// add this BarrierBlock to the queue which requires
		// that all previously added tasks must be completed
		// in order for this task to be executed - we're simply
		// handing control back over to the UI
		self.imageDownloadQueue.addBarrierBlock {
			completion(nil)
		}
	}
			
	// OJO: make sure to pass indexPath thru!!!
	func downloadImage(forImageUrlString imageUrlString: String,
										 forIndexPath indexPath: IndexPath,
										 withCompletion completion: ((UIImage?, NetworkingError?, IndexPath) -> Void)?) {
		guard let imageUrl = URL(string: imageUrlString) else {
			completion?(nil, NetworkingError.invalidUrl, indexPath)
			return
		}
		
		if let cachedImage = imageDownloadCache.object(forKey: NSString(string: imageUrlString)) {
			print("RETURNING CACHED IMAGE")
			completion?(cachedImage, nil, indexPath)
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
						completion?(nil, error, indexPath)
						return
					}
					
					guard let image = image else { return }
					
					print("CACHING IMAGE")
					
					// cache the image using the url as the key
					self.imageDownloadCache.setObject(image, forKey: NSString(string: imageUrlString))
					
					completion?(image, error, indexPath)
				}
				// add to image download queue
				imageDownloadQueue.addOperation(imageDownloadOperation)
			}
		}
	}
	
	func downloadDownsampledImage(forImageUrlString imageUrlString: String,
																forIndexPath indexPath: IndexPath,
																withImageDimensions imageDimensions: CGSize,
																withImageScale imageScale: CGFloat,
																withCompletion completion: ((UIImage?, NetworkingError?, IndexPath) -> Void)?) {
		guard let imageUrl = URL(string: imageUrlString) else {
			completion?(nil, NetworkingError.invalidUrl, indexPath)
			return
		}
		
		if let cachedImage = imageDownloadCache.object(forKey: NSString(string: imageUrlString)) {
			print("RETURNING CACHED IMAGE")
			completion?(cachedImage, nil, indexPath)
		} else {
			// we're using a serial queue with downsampled images so we check
			// if the operation is sitting ready to go in the operation queue -
			// if so, we don't want to re-add it to operation queue
			if let operations = (imageDownsampleQueue.operations as? [DownSamplingImageOperation])?
						.filter({ $0.imageUrl.absoluteString == imageUrlString && $0.isReady == true }),
				 let _ = operations.first {
				print("IMAGE OPERATION IN QUEUE")
			} else {
				let downSamplingImageOperation = DownSamplingImageOperation(imageUrl: imageUrl, imagePointSize: imageDimensions, imageScale: imageScale)
				downSamplingImageOperation.queuePriority = .veryHigh // we're not lowering queue priority for these operations
				downSamplingImageOperation.completionBlock = {
					guard let downSampledImage = downSamplingImageOperation.downSampledImage else { return }
					
					print("CACHING IMAGE")
					
					// cache the image using the url as the key
					self.imageDownloadCache.setObject(downSampledImage, forKey: NSString(string: imageUrlString))
					
					completion?(downSampledImage, nil, indexPath)
				}
				imageDownsampleQueue.addOperation(downSamplingImageOperation)
			}
		}
	}
	
	func cancelDownloadSampledImageOperation(forImageUrl imageUrl: URL) {
		// check to see if the operation is currently running or waiting
		// if so, cancel the operation
		guard let operations = (imageDownsampleQueue.operations as? [DownSamplingImageOperation])?
						.filter({ $0.imageUrl.absoluteString == imageUrl.absoluteString && ($0.isExecuting == true || $0.isReady == true) }),
					let operationToCancel = operations.first else { return }
		operationToCancel.cancel()
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
	
	func loadedHomeImageSection(_ homeImages: [HomeImageProtocol], forPhotoSectionType photoSectionType: PhotoSectionType) {
		var section = homeImagesSections[photoSectionType.rawValue]
		section.items = homeImages
		homeImagesSections[photoSectionType.rawValue] = section
	}
	
	func loadedPhotoOfTheDay(_ photoOfTheDay: Photo) {
		self.photoOfTheDay = photoOfTheDay // only need to capture reference
	}
	
	func loadedSearchResults(_ searchResults: [Photo], forSearchTerm searchTerm: String) {
		self.searchResults = (searchResults, searchTerm)
	}
}
