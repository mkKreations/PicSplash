//
//  HomeViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

class HomeViewController: UIViewController {
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
		
		configureCollectionView()
	}
	
	private func configureCollectionView() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(HomeImageCell.self, forCellWithReuseIdentifier: HomeImageCell.reuseIdentifier)
		view.addSubview(collectionView)
		
		collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	
}
