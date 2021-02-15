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
	let imageUrl: URL
	
	var imageHandler: ImageDownloadHandler?
	
	init(url: URL) {
		self.imageUrl = url
		super.init()
	}
	
	override func main() {
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
