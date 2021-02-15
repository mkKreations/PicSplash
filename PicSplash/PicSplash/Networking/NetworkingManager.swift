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
}

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
	
	private let imageDownloadQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	private let blurHashImageQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	let blurHashImageCache: NSCache<NSString, UIImage> = NSCache()
	private(set) var homeImagesSections: [PhotoSection] = [
		PhotoSection(title: "Explore", type: .explore, items: []),
		PhotoSection(title: "New", type: .new, items: []),
	]
	
	
	// MARK: network requests
	
	func dowloadHomeImagesListData(withCompletion completion: @escaping ([PhotoSection]?, NetworkingError?) -> ()) {
		// construct urlString
		var requestUrlString: String = Self.baseUrlString
		requestUrlString.append(Self.homeImagesListPath)
		requestUrlString.append(Self.clientIDPath)
		
		guard let requestUrl = URL(string: requestUrlString) else {
			completion(nil, .invalidUrl)
			return
		}

		print("OUR URL: \(requestUrl)")
		
		URLSession.shared.dataTask(with: requestUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			
			self.processHomeImagesListData(data: data, urlResponse: response, error: error, andCompletion: completion)
		}.resume()
	}
	
	func processBlurredImage(usingBlurHashString blurHashString: String, withCompletion completion: @escaping (UIImage) -> ()) {
		if let cachedBlurredImage = blurHashImageCache.object(forKey: NSString(string: blurHashString)) {
			print("RETURNING CACHED BLURRED IMAGE")
			completion(cachedBlurredImage)
			return
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
					completion(blurredImage)
				}
				// add to image queue
				blurHashImageQueue.addOperation(blurHashOperation)
			}
		}
	}
	
	// MARK: helpers to process requests
	
	private func processHomeImagesListData(data: Data?,
																				 urlResponse response: URLResponse?,
																				 error: Error?,
																				 andCompletion completion: @escaping ([PhotoSection]?, NetworkingError?) -> ()) {
		// return and capture error from server
		if let error = error {
			completion(nil, .serverError(error))
			return
		}
		
		// ensure we have successful httpResponse
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			completion(nil, .invalidResponse)
			return
		}
		
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"]) :(")
			
		// unpack data & deserialize response data into JSON
		guard let data = data,
					let jsonList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
			completion(nil, .failedDeserialization)
			return
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
		
		completion(homeImagesSections, nil)
	}
}
