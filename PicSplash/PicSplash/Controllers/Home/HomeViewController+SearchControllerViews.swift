//
//  HomeViewController+SearchControllerViews.swift
//  PicSplash
//
//  Created by Marcus on 2/13/21.
//

import UIKit

extension HomeViewController {
	fileprivate static let trendingTopMargin: CGFloat = 20.0
	
	// MARK: Trending
	
	// call this method in -viewDidLoad
	func configureTrendingCollectionView() {
		// make trendingCollectionView extend for all of collectionView - including topMargin
		trendingCollectionView.contentInset = UIEdgeInsets(top: Self.trendingTopMargin, left: 0.0, bottom: 0.0, right: 0.0)
		trendingCollectionView.collectionViewLayout = configureTrendingCompositionalLayout() // set to our custom layout
		trendingCollectionView.translatesAutoresizingMaskIntoConstraints = false
		trendingCollectionView.register(TrendingCell.self, forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
		trendingCollectionView.register(TrendingReusableView.self,
																		forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
																		withReuseIdentifier: TrendingReusableView.reuseIdentifier)
		trendingCollectionView.alpha = 0.0
		trendingCollectionView.backgroundColor = .black
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
		
		configureTrendingHeader(forSection: section) // add section header
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	func configureTrendingHeader(forSection section: NSCollectionLayoutSection) {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																						heightDimension: .absolute(48.0))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
																																		elementKind: UICollectionView.elementKindSectionHeader,
																																		alignment: .top)
		section.boundarySupplementaryItems = [sectionHeader]
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
		
		configureHomeReusableViewForDatasource()
	}
	
	private func configureHomeReusableViewForDatasource() {
		trendingDatasource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
			guard let self = self else { return nil }
			
			if kind == UICollectionView.elementKindSectionHeader {
				let currentTrendingSection = self.trendingDatasource?.snapshot().sectionIdentifiers[indexPath.section]
				
				guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																																								 withReuseIdentifier: TrendingReusableView.reuseIdentifier,
																																								 for: indexPath) as? TrendingReusableView else { return nil }
				reusableView.displayText = currentTrendingSection?.title
				return reusableView
			}
			
			return nil
		}
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