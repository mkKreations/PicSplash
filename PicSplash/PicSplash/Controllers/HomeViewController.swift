//
//  HomeViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

final class HomeViewController: UIViewController {
	// class vars
	private static let navMaxHeight: CGFloat = 320.0
	private static let navMinHeight: CGFloat = 70.0

	
	// instance vars
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: view.frame, collectionViewLayout: configureCompositionalLayout())
	}()
	private var datasource: UICollectionViewDiffableDataSource<SectionPlaceHolder, ImagePlaceholder>!
	private lazy var scrollingNavView: ScrollingNavigationView = {
		ScrollingNavigationView(frame: CGRect(origin: .zero,
																					size: CGSize(width: view.frame.width, height: Self.navMaxHeight)))
	}()
	private let loginFadeView: UIView = UIView(frame: .zero)
	private let loginView: LoginView = LoginView(frame: .zero)
	private var loginViewBottomConstraint: NSLayoutConstraint?
		
	
	// MARK: view life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureSubviews()
		configureDatasource()
		applySnapshot()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// we know our loginView will have size by now
		adjustLoginViewPositionForAppearance()
	}
		
	
	// MARK: subviews config
	
	private func configureSubviews() {
		// inset content by our scrollingNavView height
		collectionView.contentInset = UIEdgeInsets(top: Self.navMaxHeight, left: 0.0, bottom: 0.0, right: 0.0)
		collectionView.contentInsetAdjustmentBehavior = .never // by default, behavior adjusts inset 20 pts for status bar
		collectionView.showsVerticalScrollIndicator = false
		collectionView.delegate = self
		collectionView.register(HomeOrthogonalCell.self, forCellWithReuseIdentifier: HomeOrthogonalCell.reuseIdentifier)
		collectionView.register(HomeImageCell.self, forCellWithReuseIdentifier: HomeImageCell.reuseIdentifier)
		collectionView.register(HomeCollectionReusableView.self,
														forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
														withReuseIdentifier: HomeCollectionReusableView.reuseIdentifier)
		view.addSubview(collectionView)
		
		scrollingNavView.delegate = self // respond to button actions
		view.addSubview(scrollingNavView) // add after collectionView so it's on top
		
		// using frames for this view
		// configure loginFadeView but
		// don't add it to view yet
		loginFadeView.backgroundColor = UIColor.picsplashBlack.withAlphaComponent(0.7)
		loginFadeView.frame = view.frame
		loginFadeView.center = view.center
		loginFadeView.alpha = 0.0
		
		loginView.translatesAutoresizingMaskIntoConstraints = false
		loginView.delegate = self // respond to button actions
		view.addSubview(loginView) // this view on top of all
		
		layoutLoginViewForInitialAppearance()
	}
		
}



// MARK: loginView related stuff & LoginViewButtonActionsProvider

extension HomeViewController: LoginViewButtonActionsProvider {
	
	func didPressCancelButton(_ sender: UIButton) {
		dismissLoginView()
	}
	
	private func layoutLoginViewForInitialAppearance() {
		// capture bottom constraint
		loginViewBottomConstraint = view.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: 0.0)
		loginViewBottomConstraint?.isActive = true
		
		loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6.0).isActive = true
		loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6.0).isActive = true
	}

	// call this method when you know the loginView has size
	// if you lay out and constrain in viewDidLoad then your
	// view will have size by viewDidAppear and you can adjust
	// constraints without it affecting the visuals of the UI
	private func adjustLoginViewPositionForAppearance() {
		if loginViewBottomConstraint?.constant != -loginView.frame.size.height {
			loginViewBottomConstraint?.constant = -loginView.frame.size.height
		}
	}

	private func animateLoginViewAppearance() {
		let viewMidYConstant = (view.bounds.size.height / 2.0) - (loginView.bounds.size.height / 2.0)
		
		// ensure view isn't already in position
		// should never happen but never know
		guard loginViewBottomConstraint?.constant != viewMidYConstant else { return }
		
		loginViewBottomConstraint?.constant = viewMidYConstant

		// add loginFadeView to view subviews
		// should already be removed from dismissLoginView
		if !view.subviews.contains(loginFadeView) {
			view.insertSubview(loginFadeView, belowSubview: loginView)
		}

		UIView.animate(withDuration: 0.6,
									 delay: 0.0, options: .curveEaseInOut, animations: {
										self.loginFadeView.alpha = 1.0
										self.view.layoutIfNeeded()
									 }, completion: nil)
	}
	
	private func dismissLoginView() {
		let dismissYConstant = -loginView.frame.size.height
		
		// ensure view isn't already in position
		// should never happen but never know
		guard loginViewBottomConstraint?.constant != dismissYConstant else { return }
		
		loginViewBottomConstraint?.constant = dismissYConstant

		UIView.animate(withDuration: 0.6,
									 delay: 0.0, options: .curveEaseInOut) {
			self.loginFadeView.alpha = 0.0
			self.view.layoutIfNeeded()
		} completion: { complete in
			if complete {
				self.loginFadeView.removeFromSuperview() // remove loginFadeView
			}
		}
	}

}


	
// MARK: scrollNavView button actions

extension HomeViewController: ScrollingNavigationButtonsProvider {
	// delegate methods
	
	func didPressMenuButton(_ button: UIButton) {
		// present fresh instance of menu VC modally via sheet
		present(MenuViewController(), animated: true, completion: nil)
	}
	
	func didPressLogInButton(_ button: UIButton) {
		animateLoginViewAppearance()
	}
	
}



// MARK: compositional layout

extension HomeViewController {
	
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

}



// MARK: diffable datasource

extension HomeViewController {
	
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



// MARK: scrollview delegate methods

extension HomeViewController: UICollectionViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// offset will begin as negative from origin since
		// we're using contentInsets on collectionView, so
		// we'll negate it to work with positive values
		let offset: CGFloat = -scrollView.contentOffset.y
		
		// set restriction on min height for scrollingNavView
		let height: CGFloat = max(offset, Self.navMinHeight)
		
		// update frames
		var scrollNavViewFrame: CGRect = scrollingNavView.frame
		scrollNavViewFrame.size.height = height
		scrollingNavView.frame = scrollNavViewFrame
		
		// logic to pass percentage increase/decrease values to scrollingNavView
		
		// nothing to do here for now
		// if we're scaling into scrollingNavView by scrolling down
		// when at top or when scrollView bounces at rest point
		if height > Self.navMaxHeight {
			// old number = Self.navMaxHeight
			// new number = height
//			let increase = height - Self.navMaxHeight
//			let percentIncrease = increase / Self.navMaxHeight * 100
//			print("So we increasing now? \(percentIncrease / 100)")
			return
		}
		
		// logic for percent decrease - primarily
		// when scrolling down & back up
		let desiredScrollRange: CGFloat = Self.navMaxHeight - Self.navMinHeight // represents old number
		let absoluteHeight = abs(height - Self.navMaxHeight) // represents new number
		let decrease = desiredScrollRange - absoluteHeight
		let percentDecrease = decrease / desiredScrollRange
		print("Percent Decrease? \(percentDecrease)")
		scrollingNavView.animateSubviews(forScrollDelta: percentDecrease)
	}
	
}
