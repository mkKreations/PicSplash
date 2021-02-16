//
//  PhotoOfTheDayOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/16/21.
//

import UIKit

// AsyncOperation to get our Photo of the Day

class PhotoOfTheDayOperation: AsyncOperation {
	// instance vars
	
	private let photoOfTheDayUrl: URL
	private var photoOfTheDay: Photo?
	private let internalQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .userInteractive
		return operationQueue
	}()
	weak var delegate: NetworkingOperationsProtocol?
	
	
	// inits
	
	init(photoOfTheDayUrl: URL) {
		self.photoOfTheDayUrl = photoOfTheDayUrl
		super.init()
	}
	
	
	// main
	
	override func main() {
		URLSession.shared.dataTask(with: photoOfTheDayUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			// process our photo of the day and
			// pass it off to our delegate
			try? self.processPhotoOfTheDayData(data: data, response: response, error: error)

			// draw blurred image for photo of the day
			
			// we know we'll have this photoOfTheDay
			// at this point- no need to throw error
			guard let photoBlurHash = self.photoOfTheDay?.blurString else { return }
			let blurHashOperation = BlurHashOperation(blurHash: photoBlurHash)
			blurHashOperation.queuePriority = .veryHigh
			blurHashOperation.completionBlock = {
				// get our blurred image & pass off to delegate for caching
				guard let blurredImage = blurHashOperation.blurredImage else { return }
				self.delegate?.cacheBlurredImage(blurredImage, forBlurHash: photoBlurHash)
			}
			self.internalQueue.addOperation(blurHashOperation) // add operation to internal queue
			
			// adding a barrierBlock ensures that all previous tasks on this queue will be completed
			// before running this task. within here, we're declaring our state as finished so our
			// OperationQueue will accurately know that our main() task has now completed
			self.internalQueue.addBarrierBlock {
				self.state = .finished
			}
		}.resume()
	}
	
	
	//
	
	private func processPhotoOfTheDayData(data: Data?, response: URLResponse?, error: Error?) throws {
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
					let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
			throw NetworkingError.failedDeserialization
		}
		
		// unpack necessary vars
		guard let urlsDict = json["urls"] as? [String: String],
					let imageUrl = urlsDict["small"],
					let userDict = json["user"] as? [String: Any],
					let username = userDict["username"] as? String,
					let blurHash = json["blur_hash"] as? String,
					let width = json["width"] as? Int,
					let height = json["height"] as? Int else {
			throw NetworkingError.failedDataProcessing
		}

		// create our photo of the day
		let photoOfTheDay = Photo(imageUrl: imageUrl,
															author: username,
															blurString: blurHash,
															height: height,
															width: width)

		// capture reference for ourself
		self.photoOfTheDay = photoOfTheDay

		// pass it off to delegate
		delegate?.loadedPhotoOfTheDay(photoOfTheDay)
	}
	
}
