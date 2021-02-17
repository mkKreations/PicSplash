//
//  HomeImageProtocol.swift
//  PicSplash
//
//  Created by Marcus on 2/14/21.
//

import UIKit

// this protocol will allow various types to
// be used with our PhotoSection object within
// any diffable datasource, this section object
// will have an array of these HomeImageProtocol items

protocol HomeImageProtocol: AnyObject {
	var displayText: String? { get }
	var imageUrlString: String { get }
	var blurHashString: String { get }
	var imageWidth: Int { get }
	var imageHeight: Int { get }
}

// default values so every class that conforms
// doesn't have to implement every var/func

extension HomeImageProtocol {
	var imageWidth: Int {
		0
	}
	
	var imageHeight: Int {
		0
	}
}
