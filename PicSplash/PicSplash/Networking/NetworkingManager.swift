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
	
	// instance vars
	private var homeImageUrls: [URL] = []
	
	private let imageDownloadQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	
	func dowloadHomeImagesListData(withCompletion completion: @escaping ([Any]?, NetworkingError?) -> ()) {
		// construct urlString
		var requestUrlString: String = Self.baseUrlString
		requestUrlString.append(Self.homeImagesListPath)
		requestUrlString.append(Self.clientIDPath)
		
		guard let requestUrl = URL(string: requestUrlString) else { return }

		print("OUR URL: \(requestUrl)")
		
		URLSession.shared.dataTask(with: requestUrl) { data, response, error in
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
						let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
				completion(nil, .failedDeserialization)
				return
			}
			
			completion(json, nil)
		}.resume()
	}
}
