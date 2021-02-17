//
//  Collection.swift
//  PicSplash
//
//  Created by Marcus on 2/16/21.
//

import Foundation

final class Collection {
	let id: Int
	let title: String
	let blurHash: String
	let imageUrl: String
	
	init(id: Int, title: String, blurHash: String, imageUrl: String) {
		self.id = id
		self.title = title
		self.blurHash = blurHash
		self.imageUrl = imageUrl
	}
}

extension Collection: Hashable {
	static func == (lhs: Collection, rhs: Collection) -> Bool {
			lhs.id == rhs.id &&
			lhs.title == rhs.title &&
			lhs.blurHash == rhs.blurHash &&
			lhs.imageUrl == rhs.imageUrl
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(title)
		hasher.combine(blurHash)
		hasher.combine(imageUrl)
	}
}

extension Collection: HomeImageProtocol {
	var displayText: String? {
		title
	}
	
	var displayImageUrlString: String? {
		imageUrl
	}
}
