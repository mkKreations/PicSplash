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
	private let blurHashImageQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	private let blurHashImageCache: NSCache<NSString, UIImage> = NSCache()
	private(set) var homeImagesSections: [PhotoSection] = [
		PhotoSection(title: "Explore", type: .explore, items: []),
		PhotoSection(title: "New", type: .new, items: []),
	]
	
	
	// MARK: network requests
	
	func downloadHomeInitialData(withCompletion completion: @escaping (NetworkingError?) -> ()) {
		// construct urlString
		var requestUrlString: String = Self.baseUrlString
		requestUrlString.append(Self.homeImagesListPath)
		requestUrlString.append(Self.clientIDPath)
		
		guard let requestUrl = URL(string: requestUrlString) else {
			completion(.invalidUrl)
			return
		}

		print("OUR URL: \(requestUrl)")
		
		URLSession.shared.dataTask(with: requestUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			
			// process our home images list data
			try? self.processHomeImagesListData(data: data, urlResponse: response, error: error)
			
			// load first couple of blurred images for both sections
			
			// get indexPaths of the items whose blurred images we want to load
			let newSection: Int = PhotoSectionType.new.rawValue
			let firstNewCellIndexPath = IndexPath(row: 0, section: newSection)
			let secondNewCellIndexPath = IndexPath(row: 1, section: newSection)
			
			let exploreSection: Int = PhotoSectionType.explore.rawValue
			let firstExploreCellIndexPath = IndexPath(row: 0, section: exploreSection)
			let secondExploreCellIndexPath = IndexPath(row: 1, section: exploreSection)

			// create operations & cache results from those indexPaths
			[firstNewCellIndexPath, secondNewCellIndexPath, firstExploreCellIndexPath, secondExploreCellIndexPath].forEach { indexPath in
				// get photo
				let photo = self.homeImagesSections[indexPath.section].items[indexPath.row]
				
				// we know that operations will be created for these tasks since
				// this is initial load - also we know that the blurred images will
				// be cached using their blurString
				self.processBlurredImage(usingBlurHashString: photo.blurString, withCompletion: nil)
			}
			
			// adding a barrierBlock ensures that all previous tasks on this queue will be completed
			// before running this task. within here, we're just calling our completion block to hand
			// control back over to the UI - important to deploy barrier block on correct queue
			self.blurHashImageQueue.addBarrierBlock {
				completion(nil)
			}
			
		}.resume()
	}
	
	func processBlurredImage(usingBlurHashString blurHashString: String, withCompletion completion: ((UIImage) -> ())?) {
		if let cachedBlurredImage = blurHashImageCache.object(forKey: NSString(string: blurHashString)) {
			print("RETURNING CACHED BLURRED IMAGE")
			completion?(cachedBlurredImage)
		} else {
			// first see if the operation is currently running on blurHashImageQueue
			// if so - do nothing as of now since operation already has highest queue priority
			if let operations = (blurHashImageQueue.operations as? [BlurHashOperation])?
					.filter({ $0.blurHash == blurHashString && $0.isExecuting && $0.isFinished == false }),
				 let _ = operations.first {
				print("BLURRED IMAGE OPERATION CURRENTLY RUNNING")
			} else {
				let blurHashOperation = BlurHashOperation(blurHash: blurHashString)
				blurHashOperation.queuePriority = .veryHigh
				blurHashOperation.completionBlock = {
					// make sure the operation completed & we have a blurredImage
					guard let blurredImage = blurHashOperation.blurredImage else { return }

					print("CACHING BLURRED IMAGE")
					
					// cache the image using the blur hash as the key
					self.blurHashImageCache.setObject(blurredImage, forKey: NSString(string: blurHashString))
					completion?(blurredImage)
				}
				// add to blur hash queue
				blurHashImageQueue.addOperation(blurHashOperation)
			}
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
			completion?(cachedImage, nil)
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
	
	// MARK: helpers to process requests
	
	private func processHomeImagesListData(data: Data?,
																				 urlResponse response: URLResponse?,
																				 error: Error?) throws {
		// return and capture error from server
		if let error = error {
			throw NetworkingError.serverError(error)
		}
		
		// ensure we have successful httpResponse
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			throw NetworkingError.invalidResponse
		}
		
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"]) :(")
			
		// unpack data & deserialize response data into JSON
		guard let data = data,
					let jsonList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
			throw NetworkingError.failedDeserialization
		}
		
		// get the section we want to modify - we know we'll have them - no need to bail out
		guard var photoExploreSection = homeImagesSections.filter({ $0.type == .explore }).first else { return }
		guard var photoNewSection = homeImagesSections.filter({ $0.type == .new }).first else { return }

		// the mapping of JSON data to our object is not 1 to 1 so we unpack the old fashioned way
		// and append the data to our homeImagesSections - also handle blurHash
		jsonList.forEach { item in
			guard let blurHashString: String = item["blur_hash"] as? String,
						let width: Int = item["width"] as? Int,
						let height: Int = item["height"] as? Int,
						let userDict: [String: Any] = item["user"] as? [String: Any],
						let userName: String = userDict["username"] as? String,
						let urlsDict: [String: String] = item["urls"] as? [String: String],
						let imageUrl: String = urlsDict["small"]
			else { return } // should I throw NetworkError here?
			
			photoExploreSection.items.append(Photo(imageUrl: imageUrl,
																						 author: userName,
																						 blurString: blurHashString,
																						 height: height,
																						 width: width))
			photoNewSection.items.append(Photo(imageUrl: imageUrl,
																				 author: userName,
																				 blurString: blurHashString,
																				 height: height,
																				 width: width))
			
		}
//		print("JSON DATA: \(jsonList)")
		
		// reset data on our property
		homeImagesSections[0] = photoExploreSection
		homeImagesSections[1] = photoNewSection
	}
}
