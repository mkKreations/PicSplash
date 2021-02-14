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
		trendingCollectionView.collectionViewLayout = configureTrendingCompositionalLayout() // set to our custom layout
		trendingCollectionView.translatesAutoresizingMaskIntoConstraints = false
		trendingCollectionView.register(TrendingCell.self, forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
		trendingCollectionView.alpha = 0.0
		trendingCollectionView.backgroundColor = .picSplashBlack
		trendingCollectionView.isUserInteractionEnabled = false
		view.addSubview(trendingCollectionView)
		
		constrainTrendingCollectionView()
		configureTrendingDatasource()
		applyTrendingSnapshot()
	}
	
	func constrainTrendingCollectionView() {
		trendingCollectionViewTopConstraint = trendingCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0)
		trendingCollectionViewTopConstraint?.isActive = true
		trendingCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		trendingCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		trendingCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	func configureTrendingCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	func configureTrendingDatasource() {
		trendingDatasource = UICollectionViewDiffableDataSource<TrendingSection, Trending>(collectionView: trendingCollectionView, cellProvider: {
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
		trendingDatasource?.apply(trendingSnapshot, animatingDifferences: true)
	}
	
	func animateTrendingCollectionView(forAppearance willAppear: Bool, withDuration duration: TimeInterval = 0.03) {
		// set correct initial states
		if willAppear {
			trendingCollectionView.alpha = 0.0 // make sure alpha is correct value
			trendingCollectionViewTopConstraint?.constant = Self.navMinHeight
		}
		
		UIView.animate(withDuration: duration,
									 delay: 0.0, options: .curveEaseInOut) {
			self.trendingCollectionView.alpha = willAppear ? 1.0 : 0.0
			self.view.layoutIfNeeded()
		} completion: { _ in
			// enable/disable userInteraction
			self.trendingCollectionView.isUserInteractionEnabled = willAppear
						
			// manage state
			self.isShowingTrending = willAppear
		}
	}
	
	
	// MARK: SearchResults
	
	
}
