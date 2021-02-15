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
		
		guard let requestUrl = URL(string: requestUrlString) else { return }

		print("OUR URL: \(requestUrl)")
		
		URLSession.shared.dataTask(with: requestUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			
			self.processHomeImagesListData(data: data, urlResponse: response, error: error, andCompletion: completion)
		}.resume()
	}
	
	
	// MARK: helpers to process requests
	
	private func processHomeImagesListData(data: Data?,
																				 urlResponse response: URLResponse?,
																				 error: Error?,
																				 andCompletion completion: @escaping ([PhotoSection]?, NetworkingError?) -> ()) {
		if let error = error {
			completion(nil, .serverError(error))
			return
		}
		
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			completion(nil, .invalidResponse)
			return
		}
		
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"]) :(")
			
		guard let data = data,
					let jsonList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
			completion(nil, .failedDeserialization)
			return
		}
		
		// get the section we want to modify
		guard var photoExploreSection = homeImagesSections.filter({ $0.type == .explore }).first else { return }
		guard var photoNewSection = homeImagesSections.filter({ $0.type == .new }).first else { return }

		jsonList.forEach { item in
			guard let blurHashString: String = item["blur_hash"] as? String,
						let width: Int = item["width"] as? Int,
						let height: Int = item["height"] as? Int,
						let userDict: [String: Any] = item["user"] as? [String: Any],
						let userName: String = userDict["username"] as? String,
						let urlsDict: [String: String] = item["urls"] as? [String: String],
						let imageUrl: String = urlsDict["small"]
			else { return }
			
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
		print("JSON DATA: \(jsonList)")
		
		// reset data on our property
		homeImagesSections[0] = photoExploreSection
		homeImagesSections[1] = photoNewSection
		
		print("HOME IMAGE SECTION 0: \(photoExploreSection)")
		print("HOME IMAGE SECTION 1: \(photoNewSection)")

		completion(homeImagesSections, nil)
	}
}
