//
//  HomeCollectionReusableView.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

class HomeCollectionReusableView: UICollectionReusableView {
	// static vars
	static let reuseIdentifier: String = UUID().uuidString
	
	
	// inits
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in HomeCollectionReusableView")
	}
}
