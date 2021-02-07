//
//  HomeViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

final class HomeViewController: UIViewController {	
	// instance vars
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: .zero, collectionViewLayout: configureCompositionalLayout())
	}()
	private var datasource: UICollectionViewDiffableDataSource<SectionPlaceHolder, ImagePlaceholder>!
	
	
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
		collectionView.register(HomeCollectionReusableView.self,
														forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
														withReuseIdentifier: HomeCollectionReusableView.reuseIdentifier)
		view.addSubview(collectionView)
		
		constrainCollectionView()
	}
	
	private func constrainCollectionView() {
		collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			let currentSectionType = sampleData[sectionIndex].type
			
			switch currentSectionType {
			case .orthogonal:
				let section = self.sectionLayoutForHomeOrthogonalCell()
				self.createSectionHeaderLayout(forSection: section)
				return section
			case .main:
				let section = self.sectionLayoutForHomeImageCell()
				self.createSectionHeaderLayout(forSection: section)
				return section
			}
		}
		return layout
	}
	
	private func sectionLayoutForHomeOrthogonalCell() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																					heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 4.0, bottom: 0.0, trailing: 4.0)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.94),
																					 heightDimension: .absolute(140.0))
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

		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	private func createSectionHeaderLayout(forSection section: NSCollectionLayoutSection) {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
																						heightDimension: .absolute(48.0))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
																																		elementKind: UICollectionView.elementKindSectionHeader,
																																		alignment: .top)
		section.boundarySupplementaryItems = [sectionHeader]
	}
	
	private func configureDatasource() {
		datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
			(collectionView, indexPath, imagePlaceholder) -> UICollectionViewCell? in
					
			let currentSectionType = sampleData[indexPath.section].type
			
			switch currentSectionType {
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
		
		configureHomeReusableViewForDatasource()
	}
	
	private func configureHomeReusableViewForDatasource() {
		datasource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
			guard let self = self else { return nil }
			
			if kind == UICollectionView.elementKindSectionHeader {
				let currentSection = self.datasource.snapshot().sectionIdentifiers[indexPath.section]
				
				guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																																								 withReuseIdentifier: HomeCollectionReusableView.reuseIdentifier,
																																								 for: indexPath) as? HomeCollectionReusableView else { return nil }
				reusableView.displayText = currentSection.title
				reusableView.displayStyle = currentSection.type == .orthogonal ? .large : .small
				return reusableView
			}
			
			return nil
		}
	}
	
	private func applySnapshot() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionPlaceHolder, ImagePlaceholder>()
		snapshot.appendSections(sampleData)
		sampleData.forEach { sampleSection in
			snapshot.appendItems(sampleSection.images, toSection: sampleSection)
		}
		datasource.apply(snapshot)
	}
	
}
