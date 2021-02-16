//
//  ExploreCollectionsOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/16/21.
//

import Foundation

class ExploreCollectionsOperation: AsyncOperation {
	// instance vars
	
	private let url: URL
	private let internalQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	
	
	// inits
	
	init(url: URL) {
		self.url = url
		super.init()
	}
	
	
	// main
	
	override func main() {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else { return }
			
			
			
		}.resume()
	}
	
	
	// helpers
	
	private func processExploreCollectionsResponse(data: Data?, response: URLResponse?, error: Error?) throws {
		// return and capture error from server
		if let error = error {
			throw NetworkingError.serverError(error)
		}
		
		// ensure we have successful httpResponse
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			throw NetworkingError.invalidResponse
		}

		// only 50/hr
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"]) :(")

		// unpack data & deserialize response data into JSON
		guard let data = data,
					let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
			throw NetworkingError.failedDeserialization
		}

		var collections: [Collection] = []

		json.forEach { jsonDict in
			guard let coverPhotoDict = jsonDict["cover_photo"] as? [String: Any],
						let idString = coverPhotoDict["id"] as? String,
						let id = Int(idString),
						let title = coverPhotoDict["description"] as? String,
						let blurHash = coverPhotoDict["blur_hash"] as? String,
						let urlsDict = coverPhotoDict["urls"] as? [String: Any],
						let imageUrl = urlsDict["small"] as? String else { return	}

			collections.append(Collection(id: id,
																		title: title,
																		blurHash: blurHash,
																		imageUrl: imageUrl))
		}
		
		// pass collections to delegate
	}
}
