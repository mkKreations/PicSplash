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
	
	private func constrainTrendingCollectionView() {
		trendingCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: Self.navMinHeight).isActive = true
		trendingCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		trendingCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		trendingCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	private func configureTrendingCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		
		configureTrendingHeader(forSection: section) // add section header
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	private func configureTrendingHeader(forSection section: NSCollectionLayoutSection) {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																						heightDimension: .absolute(48.0))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
																																		elementKind: UICollectionView.elementKindSectionHeader,
																																		alignment: .top)
		section.boundarySupplementaryItems = [sectionHeader]
	}
	
	private func configureTrendingDatasource() {
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

	private func applyTrendingSnapshot() {
		var trendingSnapshot = NSDiffableDataSourceSnapshot<TrendingSection, Trending>()
		trendingSnapshot.appendSections(trendingData)
		trendingData.forEach { trendingSnapshot.appendItems($0.items, toSection: $0) }
		trendingDatasource?.apply(trendingSnapshot, animatingDifferences: true)
	}
	
	func animateTrendingCollectionView(forAppearance willAppear: Bool, withDuration duration: TimeInterval = 0.03) {
		UIView.animate(withDuration: duration,
									 delay: 0.0, options: .curveEaseInOut) {
			self.trendingCollectionView.alpha = willAppear ? 1.0 : 0.0
		} completion: { _ in
			// enable/disable userInteraction
			self.trendingCollectionView.isUserInteractionEnabled = willAppear
						
			// manage state
			self.isShowingTrending = willAppear
		}
	}
	
	
	
	// MARK: loading
	
	func configureLoadingViewAndIndicator() {
		loadingView.translatesAutoresizingMaskIntoConstraints = false
		loadingView.backgroundColor = .black
		loadingView.isUserInteractionEnabled = false
		loadingView.alpha = 0.0
		
		loadingActivityActivator.translatesAutoresizingMaskIntoConstraints = false
		loadingActivityActivator.alpha = 0.0
		loadingActivityActivator.isUserInteractionEnabled = false
		
		loadingView.addSubview(loadingActivityActivator)
		view.addSubview(loadingView)

		constrainLoadingViewAndActivityIndicator()
	}
	
	private func constrainLoadingViewAndActivityIndicator() {
		loadingView.topAnchor.constraint(equalTo: view.topAnchor, constant: Self.navMinHeight).isActive = true
		loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		loadingActivityActivator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
		loadingActivityActivator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
	}
	
	func animateLoadingView(forAppearance willAppear: Bool, withDuration duration: TimeInterval = 0.03) {
		loadingView.alpha = willAppear ? 0.0 : 1.0
		loadingActivityActivator.alpha = willAppear ? 0.0 : 1.0

		if willAppear {
			loadingActivityActivator.startAnimating()
		}
		
		UIView.animate(withDuration: duration,
									 delay: 0.0, options: .curveEaseInOut) {
			self.loadingView.alpha = willAppear ? 1.0 : 0.0
			self.loadingActivityActivator.alpha = willAppear ? 1.0 : 0.0
		} completion: { _ in
			// enable/disable userInteraction
			self.loadingView.isUserInteractionEnabled = willAppear
			
			// stop animating loading
			if !willAppear {				
				self.loadingActivityActivator.stopAnimating()
			}
						
			// manage state
			self.isShowingLoadingView = willAppear
		}
	}
	
	
	
	// MARK: SearchResults
	
	func configureSearchResultsCollectionView() {
		// use pre-existing cell & compositionalLayout section
		searchResultsCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: sectionLayoutForHomeImageCell())
		searchResultsCollectionView.translatesAutoresizingMaskIntoConstraints = false
		searchResultsCollectionView.register(HomeImageCell.self, forCellWithReuseIdentifier: HomeImageCell.reuseIdentifier)
		searchResultsCollectionView.alpha = 0.0
		searchResultsCollectionView.isUserInteractionEnabled = false
		view.addSubview(searchResultsCollectionView)
		
		constrainSearchResultsCollectionView()
		configureSearchResultsDatasource()
		applySearchResultsSnapshot()
	}
	
	private func constrainSearchResultsCollectionView() {
		searchResultsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		searchResultsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		searchResultsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: Self.navMinHeight).isActive = true
		searchResultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
	
	private func configureSearchResultsDatasource() {
		searchResultsDatasource = UICollectionViewDiffableDataSource(collectionView: searchResultsCollectionView, cellProvider: {
			(collectionView, indexPath, _) -> UICollectionViewCell? in
			
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeImageCell.reuseIdentifier,
																													for: indexPath) as? HomeImageCell else { return nil }
			
			let section = searchResultsSampleData[indexPath.section]
			
			cell.displayText = String(section.images[indexPath.row].height)
			cell.displayBackgroundColor = section.images[indexPath.row].placeholderColor
			
			return cell
		})
	}
	
	private func applySearchResultsSnapshot() {
		var searchResultsSnapshot = NSDiffableDataSourceSnapshot<SectionPlaceHolder, ImagePlaceholder>()
		searchResultsSnapshot.appendSections(searchResultsSampleData)
		searchResultsSampleData.forEach { searchResultsSnapshot.appendItems($0.images, toSection: $0) }
		searchResultsDatasource?.apply(searchResultsSnapshot)
	}
	
	func animateSearchResultsCollectionView(forAppearance willAppear: Bool,
																					withDuration duration: TimeInterval = 0.03,
																					withCompletion completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: duration,
									 delay: 0.0, options: .curveEaseInOut) {
			self.searchResultsCollectionView.alpha = willAppear ? 1.0 : 0.0
		} completion: { _ in
			// enable/disable userInteraction
			self.searchResultsCollectionView.isUserInteractionEnabled = willAppear
						
			// manage state
			self.isShowingSearchResults = willAppear
			
			// apparently closures are escaping by nature
			// if they are declared as an optional :O
			completion?()
		}
	}
	
}
