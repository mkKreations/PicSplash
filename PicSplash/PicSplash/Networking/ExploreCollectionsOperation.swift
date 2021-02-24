//
//  ExploreCollectionsOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/16/21.
//

import Foundation

// this operation is responsible for fetching the
// "Explore" section of the home collection view

class ExploreCollectionsOperation: AsyncOperation {
	// instance vars
	
	private let exploreSection: PhotoSectionType = .explore
	private let url: URL
	private let internalQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	weak var delegate: NetworkingOperationsProtocol?
	
	
	// inits
	
	init(url: URL) {
		self.url = url
		super.init()
	}
	
	
	// main
	
	override func main() {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else { return }
			
			// process our explore section list data and
			// pass off explore section to our delegate
			try? self.processExploreCollectionsResponse(data: data, response: response, error: error)
			
			// draw all blurred images for explore section
			// and hand them off to delegate for caching
			self.delegate?.homeSections[self.exploreSection.rawValue].items.forEach { collection in
				self.drawAndCacheBlurredImage(usingBlurHashString: collection.blurHashString) // we're adding these operations to internalQueue
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
			
			print("CACHING BLURRED HOMEIMAGE - COLLECTIONS")

			// pass to our delegate for caching
			self.delegate?.cacheBlurredImage(blurredImage, forBlurHash: blurHashString)
		}
		internalQueue.addOperation(blurHashOperation)
	}
	
	private func processExploreCollectionsResponse(data: Data?, response: URLResponse?, error: Error?) throws {
		// return and capture error from server
		if let error = error {
			print("\(NetworkingError.serverError(error)) - ExploreCollectionsOperation")
			throw NetworkingError.serverError(error)
		}
		
		// ensure we have successful httpResponse
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			print("\(NetworkingError.invalidResponse) - ExploreCollectionsOperation")
			throw NetworkingError.invalidResponse
		}

		// only 50/hr
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"] ?? "") :(")

		// unpack data & deserialize response data into JSON
		guard let data = data,
					let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
			print("\(NetworkingError.failedDeserialization) - ExploreCollectionsOperation")
			throw NetworkingError.failedDeserialization
		}

		var collections: [Collection] = []

		json.forEach { jsonDict in
			guard let title = jsonDict["title"] as? String,
						let coverPhotoDict = jsonDict["cover_photo"] as? [String: Any],
						let id = coverPhotoDict["id"] as? String,
						let blurHash = coverPhotoDict["blur_hash"] as? String,
						let urlsDict = coverPhotoDict["urls"] as? [String: Any],
						let imageUrl = urlsDict["regular"] as? String else { return	}
			
			collections.append(Collection(id: id,
																		title: title,
																		blurHash: blurHash,
																		imageUrl: imageUrl))
		}
		
//		print("COLLECTIONS COUNT: \(collections.count)")
		
		// pass collections to delegate
		delegate?.loadedHomeImageSection(collections, forPhotoSectionType: self.exploreSection)
	}
}
