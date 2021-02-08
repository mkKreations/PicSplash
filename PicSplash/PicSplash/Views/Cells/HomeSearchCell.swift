//
//  HomeSearchCell.swift
//  PicSplash
//
//  Created by Marcus on 2/7/21.
//

import UIKit

class HomeSearchCell: UICollectionViewCell {
	static let reuseIdentifier: String = UUID().uuidString
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	required init?(coder: NSCoder) {
		fatalError("Crash in HomeSearchCell")
	}
}
