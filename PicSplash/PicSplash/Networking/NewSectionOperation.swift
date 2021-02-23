//
//  InitialCollectionViewDataLoadOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/15/21.
//

import Foundation

// this operation is responsible for fetching the
// "New" section of the home collection view

class NewSectionOperation: AsyncOperation {
	// instance vars
	
	private let newSection: PhotoSectionType = .new
	private let requestUrl: URL
	private let internalQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	weak var delegate: NetworkingOperationsProtocol?
	
	
	// init
	
	init(initialDataToLoadUrl requestUrl: URL) {
		self.requestUrl = requestUrl
		super.init()
	}
	
	
	// main
	
	override func main() {
		URLSession.shared.dataTask(with: requestUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			
			// process our new section list data and
			// pass off new section to our delegate
			try? self.processHomeImagesListData(data: data, urlResponse: response, error: error)
			
			// draw all blurred images for new section
			// and hand them off to delegate for caching
			self.delegate?.homeSections[self.newSection.rawValue].items.forEach { photo in
				self.drawAndCacheBlurredImage(usingBlurHashString: photo.blurHashString) // we're adding these operations to internalQueue
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
	
	private func processHomeImagesListData(data: Data?,
																				 urlResponse response: URLResponse?,
																				 error: Error?) throws {
		// return and capture error from server
		if let error = error {
			print("\(NetworkingError.serverError(error)) - NewSectionOperation")
			throw NetworkingError.serverError(error)
		}
		
		// ensure we have successful httpResponse
		guard let httpResponse = response as? HTTPURLResponse,
					(200...300).contains(httpResponse.statusCode) else {
			print("\(NetworkingError.invalidResponse) - NewSectionOperation")
			throw NetworkingError.invalidResponse
		}
		
		// only 50/hr
		print("REQUESTS REMAINING: \(httpResponse.allHeaderFields["x-ratelimit-remaining"] ?? "") :(")
			
		// unpack data & deserialize response data into JSON
		guard let data = data,
					let jsonList = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
			print("\(NetworkingError.failedDeserialization) - NewSectionOperation")
			throw NetworkingError.failedDeserialization
		}
		
		// mutable array
		var newSectionPhotos: [Photo] = []

		// the mapping of JSON data to our object is not 1 to 1 so we unpack the old fashioned way
		jsonList.forEach { item in
			guard let blurHashString: String = item["blur_hash"] as? String,
						let width: Int = item["width"] as? Int,
						let height: Int = item["height"] as? Int,
						let id: String = item["id"] as? String,
						let userDict: [String: Any] = item["user"] as? [String: Any],
						let userName: String = userDict["name"] as? String,
						let urlsDict: [String: String] = item["urls"] as? [String: String],
						let imageUrl: String = urlsDict["regular"]
			else { return } // should I throw NetworkError here?
			
			newSectionPhotos.append(Photo(id: id,
																		imageUrl: imageUrl,
																		author: userName,
																		blurString: blurHashString,
																		height: height,
																		width: width))
			
		}
		
		// pass data out to our delegate
		delegate?.loadedHomeImageSection(newSectionPhotos, forPhotoSectionType: self.newSection)
	}

}
