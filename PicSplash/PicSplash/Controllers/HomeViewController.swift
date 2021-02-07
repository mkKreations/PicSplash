//
//  HomeViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

class HomeViewController: UIViewController {
	// instance vars
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: .zero, collectionViewLayout: configureCompositionalLayout())
	}()
	private var datasource: UICollectionViewDiffableDataSource<Section, ImagePlaceholder>!
		
	
	// collection view section enum
	enum Section: CaseIterable {
		case orthogonal
		case main
	}
	
	
	// MARK: view life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureCollectionView()
		configureDatasource()
		applySnapshot()
	}
	
	
	// MARK: collection view config
	
	private func configureCollectionView() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(HomeOrthogonalCell.self, forCellWithReuseIdentifier: HomeOrthogonalCell.reuseIdentifier)
		collectionView.register(HomeImageCell.self, forCellWithReuseIdentifier: HomeImageCell.reuseIdentifier)
		view.addSubview(collectionView)
		
		collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			let currentSection = Section.allCases[sectionIndex]
			
			switch currentSection {
			case .orthogonal:
				return self.sectionLayoutForHomeOrthogonalCell()
			case .main:
				return self.sectionLayoutForHomeImageCell()
			}
		}
		return layout
	}
	
	private func sectionLayoutForHomeOrthogonalCell() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																					heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
																					 heightDimension: .absolute(200.0))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
																									 subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .groupPagingCentered
		return section
	}
	
	private func sectionLayoutForHomeImageCell() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																					heightDimension: .estimated(100.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																					 heightDimension: .estimated(100.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
																								 subitems: [item])
		
		return NSCollectionLayoutSection(group: group)
	}
	
	private func configureDatasource() {
		datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
			(collectionView, indexPath, imagePlaceholder) -> UICollectionViewCell? in
					
			let currentSection = Section.allCases[indexPath.section]
			
			switch currentSection {
			case .orthogonal:
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeOrthogonalCell.reuseIdentifier,
																														for: indexPath) as? HomeOrthogonalCell else { return nil }
				
				cell.displayText = String(orthogonalPics[indexPath.row].height)
				cell.displayBackgroundColor = orthogonalPics[indexPath.row].placeholderColor
				
				return cell
			case .main:
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeImageCell.reuseIdentifier,
																														for: indexPath) as? HomeImageCell else { return nil }
				
				cell.displayText = String(samplePics[indexPath.row].height)
				cell.displayBackgroundColor = samplePics[indexPath.row].placeholderColor
				
				return cell
			}
			
		})
	}
	
	private func applySnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<Section, ImagePlaceholder>()
		snapshot.appendSections([.orthogonal, .main])
		snapshot.appendItems(orthogonalPics, toSection: .orthogonal)
		snapshot.appendItems(samplePics, toSection: .main)
		datasource.apply(snapshot)
	}
	
}
