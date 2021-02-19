//
//  ImageDownloadOperation.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import UIKit

// our Operation for asynchronously downloading images

// we're not handling any cancelling currently, we're
// managing Operation instances within NetworkingManager

class ImageDownloadOperation: AsyncOperation {
	// private var to pass in in case that the
	// user passes image url via dependencies
	// I honestly hate force unwrapping this but
	// I'm trying to pick the safest URL to man
	private static let dependencyCheckUrl: URL = URL(string: "https://www.google.com/")!
	
	private(set) var imageUrl: URL
	
	var imageHandler: ((_ image: UIImage?, _ error: NetworkingError?) -> ())?

	// OJO:
	// only use covenience init if you will
	// be passing the URL in via operation
	// dependencies, otherwise, use init
	// using a url
	convenience override init() {
		self.init(url: ImageDownloadOperation.dependencyCheckUrl)
	}
	
	init(url: URL) {
		self.imageUrl = url
		super.init()
	}
	
	override func main() {
		// check to see if we have any passed in dependencies
		let dependencyImageUrlStringOptional = dependencies.compactMap({ ($0 as? ImageDownloadUrlProvider)?.imageUrlString }).first
		
		// if it passes all checks, assign value to imageUrl
		if imageUrl == Self.dependencyCheckUrl,
			 let dependencyImageUrlString = dependencyImageUrlStringOptional,
			 let dependencyImageUrl = URL(string: dependencyImageUrlString) {
			imageUrl = dependencyImageUrl
		}
		
		URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
			guard let self = self else { return }
			
			defer { self.state = .finished } // make sure we update our state before handing off control
			
			if let error = error {
				self.imageHandler?(nil, NetworkingError.serverError(error))
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
						(200...300).contains(httpResponse.statusCode) else {
				self.imageHandler?(nil, NetworkingError.invalidResponse)
				return
			}
			
			guard let data = data,
						let image = UIImage(data: data) else {
				self.imageHandler?(nil, NetworkingError.failedDataProcessing)
				return
			}
			
			self.imageHandler?(image, nil)
		}.resume()
	}
}
