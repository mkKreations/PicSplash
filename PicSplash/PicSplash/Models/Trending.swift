//
//  Trending.swift
//  PicSplash
//
//  Created by Marcus on 2/13/21.
//

import Foundation

// this model is static data for now

struct TrendingSection {
	let title: String
	let items: [Trending]
}
extension TrendingSection: Hashable {}

struct Trending {
	let title: String
}
extension Trending: Hashable {}


// static data

let trendingData: [TrendingSection] = [
	TrendingSection(title: "Trending", items: [
		Trending(title: "love"),
		Trending(title: "carnaval"),
		Trending(title: "hearts"),
		Trending(title: "proposal"),
		Trending(title: "heart"),
	])
]
