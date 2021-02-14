//
//  HomeViewController+SearchControllerViews.swift
//  PicSplash
//
//  Created by Marcus on 2/13/21.
//

import UIKit

extension HomeViewController {
	
	// MARK: Trending
	
	// call this method in -viewDidLoad
	func configureTrendingCollectionView() {
		trendingCollectionView.frame = CGRect(origin: CGPoint(x: 0.0, y: Self.navMinHeight),
																					size: CGSize(width: view.bounds.width, height: view.bounds.height - Self.navMinHeight - 20.0))
		trendingCollectionView.center = view.center
		trendingCollectionView.register(TrendingCell.self, forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
		trendingCollectionView.alpha = 0.0
		trendingCollectionView.backgroundColor = .picSplashBlack
		trendingCollectionView.isUserInteractionEnabled = false
//		view.addSubview(trendingCollectionView)
	}
	
	func configureTrendingCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.9))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	func configureTrendingDatasource(withCollectionView collectionView: UICollectionView) {
		trendingDatasource = UICollectionViewDiffableDataSource<TrendingSection, Trending>(collectionView: collectionView, cellProvider: {
			(collectionView, indexPath, _) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseIdentifier,
																													for: indexPath) as? TrendingCell else { return nil }
			
			// only 1 section
			let currentSection = trendingData[indexPath.section]
			
			cell.displayText = currentSection.items[indexPath.row].title
			
			return cell
		})
	}
	
	func applyTrendingSnapshot() {
		var trendingSnapshot = NSDiffableDataSourceSnapshot<TrendingSection, Trending>()
		trendingSnapshot.appendSections(trendingData)
		trendingData.forEach { trendingSnapshot.appendItems($0.items, toSection: $0) }
		trendingDatasource?.apply(trendingSnapshot)
	}
	
	
	
	// MARK: SearchResults
	
	
}
