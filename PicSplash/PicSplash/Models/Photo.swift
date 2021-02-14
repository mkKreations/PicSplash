//
//  Photo.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import Foundation

final class Photo {
	let id: UUID = UUID() // unique ID to help distinguish value type instances
	let imageUrl: String
	let author: String
	let blurString: String
	
	init(imageUrl: String, author: String, blurString: String) {
		self.imageUrl = imageUrl
		self.author = author
		self.blurString = blurString
	}
}

// for diffable datasource
extension Photo: Hashable {
	static func == (lhs: Photo, rhs: Photo) -> Bool {
		lhs.id == rhs.id // id is enough to make it unique
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id) // id is enough to make it unique
	}

}

extension Photo: HomeImageProtocol {
	var displayText: String? {
		author
	}
	
	var displayImageUrlString: String? {
		imageUrl
	}
}
