//
//  PhotoSection.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import Foundation

enum PhotoSectionType {
	case explore
	case new
}

struct PhotoSection {
	let id: UUID = UUID() // unique ID to help distinguish value type instances
	let title: String
	let type: PhotoSectionType
//	var items: [HomeImageProtocol]
	var items: [Photo]
}

extension PhotoSection: Hashable {
	static func == (lhs: PhotoSection, rhs: PhotoSection) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
