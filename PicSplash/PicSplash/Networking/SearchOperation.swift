//
//  SearchOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/18/21.
//

import Foundation

typealias ResultsHandler = (_ results: [Photo]?, _ error: NetworkingError?) -> ()

// this operation subclass will
// be responsible for search

class SearchOperation: AsyncOperation {
	private let url: URL
	
	var resultsHandler: ResultsHandler?
	
	init(url: URL) {
		self.url = url
		super.init()
	}
	
	override func main() {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else { return }
			
			defer { self.state = .finished } // make sure we set our state to finished before leaving
			
			// return and capture error from server
			if let error = error {
				self.resultsHandler?(nil, NetworkingError.serverError(error))
				return
			}
			
			// ensure we have successful httpResponse
			guard let httpResponse = response as? HTTPURLResponse,
						(200...300).contains(httpResponse.statusCode) else {
				self.resultsHandler?(nil, NetworkingError.invalidResponse)
				return
			}
			
			// unpack data & deserialize response data into JSON
			guard let data = data,
						let jsonList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
				self.resultsHandler?(nil, NetworkingError.failedDeserialization)
				return
			}
			
			// get & append our results
			var results: [Photo] = []
			jsonList.forEach { jsonDict in
				guard let id = jsonDict["id"] as? String,
							let width = jsonDict["width"] as? Int,
							let height = jsonDict["height"] as? Int,
							let blurHash = jsonDict["blur_hash"] as? String,
							let urlsDict = jsonDict["urls"] as? [String: Any],
							let imageUrl = urlsDict["small"] as? String,
							let userDict = jsonDict["user"] as? [String: Any],
							let username = userDict["username"] as? String
				else { return } // should I throw NetworkError here?
				
				results.append(Photo(id: id,
														 imageUrl: imageUrl,
														 author: username,
														 blurString: blurHash,
														 height: height,
														 width: width))
			}
			
			self.resultsHandler?(results, nil) // success
		}
	}
}
