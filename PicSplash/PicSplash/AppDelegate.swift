//
//  AppDelegate.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let homeVC: HomeViewController = HomeViewController()
		
		window?.rootViewController = homeVC
		window?.makeKeyAndVisible()
		
		return true
	}

}
