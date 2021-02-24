//
//  UIDevice+extensions.swift
//  PicSplash
//
//  Created by Marcus on 2/24/21.
//

import UIKit

// extension to help us determine if device has notch or not

extension UIDevice {
	var hasNotch: Bool {
		// keyWindow is "deprecated" but as long as we know that
		// we're not supporting iPad - we're fine
		let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
		return bottom > 0
	}
}
