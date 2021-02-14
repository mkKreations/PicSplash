//
//  Photo.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import Foundation

struct Photo {
	let id: UUID = UUID() // unique ID to help distinguish value type instances
	let imageUrl: String
	let author: String
	let blurString: String
}

// for diffable datasource
extension Photo: Hashable {}
