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
	let height: Int
	let width: Int
	
	init(imageUrl: String, author: String, blurString: String, height: Int, width: Int) {
		self.imageUrl = imageUrl
		self.author = author
		self.blurString = blurString
		self.height = height
		self.width = width
	}
}

// for diffable datasource
extension Photo: Hashable {
	static func == (lhs: Photo, rhs: Photo) -> Bool {
			lhs.id == rhs.id &&
			lhs.imageUrl == rhs.imageUrl &&
			lhs.author == rhs.author &&
			lhs.blurString == rhs.blurString &&
			lhs.height == rhs.height &&
			lhs.width == rhs.width
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(imageUrl)
		hasher.combine(author)
		hasher.combine(blurString)
		hasher.combine(height)
		hasher.combine(width)
	}

}

extension Photo: HomeImageProtocol {
	var displayText: String? {
		author
	}
	
	var imageUrlString: String {
		imageUrl
	}
	
	var blurHashString: String {
		blurString
	}
	
	var imageWidth: Int {
		width
	}
	
	var imageHeight: Int {
		height
	}
}
