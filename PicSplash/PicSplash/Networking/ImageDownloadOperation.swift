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
	private let url: URL
	
	init(url: URL) {
		self.url = url
		super.init()
	}
	
	override func main() {
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else { return }
			
			defer { self.state = .finished } // make sure we update our state before handing off control
			
			if let _ = error {
				// call completion here and pass thru error
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
						(200...300).contains(httpResponse.statusCode) else {
				// call completion here and pass thru error
				return
			}
			
			guard let data = data,
						let _ = UIImage(data: data) else {
				// call completion here and pass thru error
				return
			}
			
			// call completion handler and pass thru image
		}
	}
}
