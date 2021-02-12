//
//  ImagePlaceholder.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

struct SectionPlaceHolder {
	enum SectionType {
		case orthogonal
		case main
	}
	
	let id = UUID()
	let title: String
	let type: SectionType
	let images: [ImagePlaceholder]
}
extension SectionPlaceHolder: Hashable {}

struct ImagePlaceholder {
	let id = UUID()
	// MARK: placeholder data
	let height: Int = Int.random(in: 50...500)
	let placeholderColor: UIColor = {
		let colors: [UIColor] = [
			.red,
			.gray,
			.green,
			.darkGray,
			.cyan,
			.systemPink,
			.brown,
			.magenta,
			.blue,
			.lightGray,
			.gray,
			.purple,
			.systemIndigo,
			.systemYellow,
		]
		guard let color = colors.randomElement() else {
			return .black
		}
		return color
	}()
	
}

// all stored properties are already Hashable so no need to define
extension ImagePlaceholder: Hashable {}


var samplePics = [
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
]
var orthogonalPics = [
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
	ImagePlaceholder(),
]


// TODO: Delete later
let sampleData = [
	SectionPlaceHolder(title: "Explore", type: .orthogonal, images: orthogonalPics),
	SectionPlaceHolder(title: "New", type: .main, images: samplePics),
]
