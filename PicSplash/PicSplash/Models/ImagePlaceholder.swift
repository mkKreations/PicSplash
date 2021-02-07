//
//  ImagePlaceholder.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

struct ImagePlaceholder {
	let id = UUID()
	
	// MARK: placeholder data
	let height: Int = Int.random(in: 50...500)
	lazy var placeholderColor: UIColor = {
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



// TODO: Delete later
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
