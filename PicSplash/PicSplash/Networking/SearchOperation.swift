//
//  SearchOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/18/21.
//

import Foundation

// this operation subclass will
// be responsible for search

class SearchOperation: AsyncOperation {
	// instance vars
	
	private let requestUrl: URL
	private let searchTerm: String
	private var results: [Photo] = []
	private let internalQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	weak var delegate: NetworkingOperationsProtocol?
	
	
	// inits
	
	init(requestUrl: URL, searchTerm: String) {
		self.requestUrl = requestUrl
		self.searchTerm = searchTerm
		super.init()
	}
	
	
	// main
	
	override func main() {
		URLSession.shared.dataTask(with: requestUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			
			// process our search results data
			// and capture reference to results
			try? self.processSearchResultsData(data: data, response: response, error: error)
			
			// draw all blurred images for new section
			// and hand them off to delegate for caching
			self.results.forEach { photo in
				self.drawAndCacheBlurredImage(usingBlurHashString: photo.blurString)
			}
			
			// adding a barrierBlock ensures that all previous tasks on this queue will be completed
			// before running this task. within here, we're declaring our state as finished so our
			// OperationQueue will accurately know that our main() task has now completed
			self.internalQueue.addBarrierBlock {
				self.state = .finished
			}
		}.resume()
	}
	
	
	// helpers
	
	private func drawAndCacheBlurredImage(usingBlurHashString blurHashString: String) {
		let blurHashOperation = BlurHashOperation(blurHash: blurHashString)
		blurHashOperation.queuePriority = .veryHigh
		blurHashOperation.completionBlock = {
			// make sure the operation completed & we have a blurredImage
			guard let blurredImage = blurHashOperation.blurredImage else { return }
			
			print("CACHING BLURRED HOMEIMAGE - PHOTO")
			
			// pass to our delegate for caching
			self.delegate?.cacheBlurredImage(blurredImage, forBlurHash: blurHashString)
		}
		internalQueue.addOperation(blurHashOperation)
	}
	
	private func processSearchResultsData(data: Data?, response: URLResponse?, error: Error?) throws {
		// return and capture error from server
		if let error = error {
			print("\(NetworkingError.serverError(error)) - SearchOperation")
			throw NetworkingError.serverError(error)
		}
		
		// ensure we have successful httpResponse
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			print("\(NetworkingError.invalidResponse) - SearchOperation")
			throw NetworkingError.invalidResponse
		}
		
		// only 50/hr
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"] ?? "") :(")

		guard let data = data,
					let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
					let resultsList = json["results"] as? [[String: Any]] else {
			print("\(NetworkingError.failedDeserialization) - SearchOperation")
			throw NetworkingError.failedDeserialization
		}
		
		// get & append our results
		var results: [Photo] = []
		resultsList.forEach { resultsDict in
			guard let id = resultsDict["id"] as? String,
						let width = resultsDict["width"] as? Int,
						let height = resultsDict["height"] as? Int,
						let blurHash = resultsDict["blur_hash"] as? String,
						let urlsDict = resultsDict["urls"] as? [String: Any],
						let imageUrl = urlsDict["regular"] as? String,
						let userDict = resultsDict["user"] as? [String: Any],
						let username = userDict["name"] as? String
			else { return } // should I throw NetworkError here?
			
			results.append(Photo(id: id,
													 imageUrl: imageUrl,
													 author: username,
													 blurString: blurHash,
													 height: height,
													 width: width))
		}

		// capture reference
		self.results = results

		// pass data out to our delegate
		delegate?.loadedSearchResults(results, forSearchTerm: searchTerm)
	}

}
