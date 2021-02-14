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
	var displayImageUrlString: String? { get }
}
