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
	private static let navSnapToTopBuffer: CGFloat = 150.0

	
	// instance vars
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: view.frame, collectionViewLayout: configureCompositionalLayout())
	}()
	private var datasource: UICollectionViewDiffableDataSource<SectionPlaceHolder, ImagePlaceholder>!
	lazy var scrollingNavView: ScrollingNavigationView = { // expose to public for view controller transition
		ScrollingNavigationView(frame: CGRect(origin: .zero,
																					size: CGSize(width: view.frame.width, height: Self.navMaxHeight)))
	}()
	private let loginFadeView: UIView = UIView(frame: .zero)
	private let loginView: LoginView = LoginView(frame: .zero)
	private var loginViewBottomConstraint: NSLayoutConstraint?
	var selectedCell: HomeImageCell? // view controller transition
	var selectedCellImageSnapshot: UIView? // view controller transition
	private var isShowingLoginView: Bool = false
		
	
	// MARK: view life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureSubviews()
		configureDatasource()
		applySnapshot()
		
		// TODO: remove this to unsilence constraint breaks from estimated cell heights
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// add ourselves as keyboard notification observer
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(keyboardWillShow(notification:)),
																					 name: UIResponder.keyboardWillShowNotification,
																					 object: nil)
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(keyboardWillHide(notification:)),
																					 name: UIResponder.keyboardWillHideNotification,
																					 object: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// we know our loginView will have size by now
		adjustLoginViewPositionForAppearance()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		// remove ourselves as observer
		NotificationCenter.default.removeObserver(self)
	}
		
	
	// MARK: subviews config
	
	private func configureSubviews() {
		// inset content by our scrollingNavView height
		collectionView.contentInset = UIEdgeInsets(top: Self.navMaxHeight, left: 0.0, bottom: 0.0, right: 0.0)
		collectionView.contentInsetAdjustmentBehavior = .never // by default, behavior adjusts inset 20 pts for status bar
		collectionView.scrollsToTop = true // ensure value is true
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
		loginFadeView.backgroundColor = UIColor.picSplashBlack.withAlphaComponent(0.7)
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
	
	func didPressLoginButton(_ sender: UIButton) {
		print("LOGIN")
	}
	
	func didPressForgotPasswordButton(_ sender: UIButton) {
		print("FORGOT PASSWORD")
	}
	
	func didPressNoAccountJoinButton(_ sender: UIButton) {
		print("NO ACCOUNT - JOIN")
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

		UIView.animate(withDuration: 0.3,
									 delay: 0.0, options: .curveEaseOut) {
			self.loginFadeView.alpha = 1.0
			self.view.layoutIfNeeded()
		} completion: { complete in
			self.isShowingLoginView = true
		}
	}
	
	private func dismissLoginView() {
		let dismissYConstant = -loginView.frame.size.height
		
		// ensure view isn't already in position
		// should never happen but never know
		guard loginViewBottomConstraint?.constant != dismissYConstant else { return }
		
		loginViewBottomConstraint?.constant = dismissYConstant

		UIView.animate(withDuration: 0.3,
									 delay: 0.0, options: .curveEaseOut) {
			self.loginFadeView.alpha = 0.0
			self.view.layoutIfNeeded()
		} completion: { complete in
			if complete {
				self.loginFadeView.removeFromSuperview() // remove loginFadeView
				self.isShowingLoginView = false
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



// MARK: collectionView delegate & relevant methods

extension HomeViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let selectedSectionPlaceholder = sampleData[indexPath.section]
		
		// nothing to do for orthogonal cells for now
		if selectedSectionPlaceholder.type == .orthogonal { return }
		
		let selectedImagePlaceholder = selectedSectionPlaceholder.images[indexPath.row]
		// capture vars for view controller transition
		selectedCell = collectionView.cellForItem(at: indexPath) as? HomeImageCell
		selectedCellImageSnapshot = selectedCell?.displayImageView.snapshotView(afterScreenUpdates: false)
		presentDetailViewController(withImagePlaceholder: selectedImagePlaceholder)
	}
	
	private func presentDetailViewController(withImagePlaceholder imagePlaceholder: ImagePlaceholder) {
		let detailVC = DetailViewController(imagePlaceholder: imagePlaceholder)
		detailVC.transitioningDelegate = self
		detailVC.modalPresentationStyle = .fullScreen
		present(detailVC, animated: true, completion: nil)
	}
		
}



// MARK: transitionDelegate conformance for DetailViewController

extension HomeViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController,
													 presenting: UIViewController,
													 source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		
		// use default animation if we don't receive parameters
		guard let homeViewController = presenting as? HomeViewController,
					let detailViewController = presented as? DetailViewController,
					let selectedCellImageSnapshot = selectedCellImageSnapshot else { return nil }
		
		let detailAnimator = DetailAnimator(presentationType: .present,
																				homeViewController: homeViewController,
																				detailViewController: detailViewController,
																				selectedImageViewSnapshot: selectedCellImageSnapshot)
		return detailAnimator
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		// use default animation if we don't receive parameters
		guard let detailViewController = dismissed as? DetailViewController,
					let selectedCellImageSnapshot = selectedCellImageSnapshot else { return nil }
		
		let detailAnimator = DetailAnimator(presentationType: .dismiss,
																				homeViewController: self,
																				detailViewController: detailViewController,
																				selectedImageViewSnapshot: selectedCellImageSnapshot)
		return detailAnimator
	}
	
}



// MARK: detailVC delegate - button actions

extension HomeViewController: DetailButtonActionsProvider {
	
	func didPressCloseButton(_ sender: UIButton) {
		// detailVC closes itself but we still receive action
		print("CLOSE")
	}
	
	func didPressShareButton(_ sender: UIButton) {
		print("SHARE")
	}
	
}



// MARK: scrollview delegate & relevant methods

extension HomeViewController {
	
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
		if height > Self.navMaxHeight { return }
		
		// logic for percent decrease - primarily
		// when scrolling down & back up
		let desiredScrollRange: CGFloat = Self.navMaxHeight - Self.navMinHeight // represents old number
		let absoluteHeight = abs(height - Self.navMaxHeight) // represents new number
		let decrease = desiredScrollRange - absoluteHeight
		let percentDecrease = decrease / desiredScrollRange
		scrollingNavView.animateSubviews(forScrollDelta: percentDecrease)
	}
		
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// accurately determine when scrollView has finished scrolling
		if !decelerate {
			trackDecelerationForScrollToTop(scrollView)
		}
	}
	
	// accurately determine when scrollView has finished scrolling
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		trackDecelerationForScrollToTop(scrollView)
	}
	
	private func trackDecelerationForScrollToTop(_ scrollView: UIScrollView) {
		let offset = -scrollView.contentOffset.y
		
		if offset < Self.navSnapToTopBuffer && offset > Self.navMinHeight {
			snapScrollViewContentToTop(scrollView)
		}
	}
	
	private func snapScrollViewContentToTop(_ scrollView: UIScrollView) {
		UIView.animate(withDuration: 0.3,
									 delay: 0.0,
									 options: .curveEaseInOut,
									 animations: {
										// update contentOffset of collectionView
										scrollView.contentOffset = CGPoint(x: 0.0, y: -Self.navMinHeight)
										self.view.layoutIfNeeded() // force update view
									 }, completion: nil)
	}
	
}



// MARK: keyboard observer methods

extension HomeViewController {
	
	@objc func keyboardWillShow(notification: NSNotification) {
		print("keyboard will show!")
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		print("keyboard will hide!")
	}
	
}
