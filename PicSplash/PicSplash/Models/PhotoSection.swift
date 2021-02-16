//
//  PhotoSection.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import Foundation

// the Int raw values will
// represent indexPath.section

enum PhotoSectionType: Int, CaseIterable {
	case explore = 0
	case new = 1
	
	var sectionTitle: String {
		switch self {
		case .explore:
			return "Explore"
		case .new:
			return "New"
		}
	}
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
