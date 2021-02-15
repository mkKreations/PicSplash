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
	static let navMinHeight: CGFloat = 70.0
	private static let navSnapToTopBuffer: CGFloat = 150.0
	static let trendingAnimationDuration: TimeInterval = 0.4

	
	// instance vars
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: view.frame, collectionViewLayout: configureCompositionalLayout())
	}()
	private var datasource: UICollectionViewDiffableDataSource<PhotoSection, Photo>!
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
	private var isObservingKeyboard: Bool = false
	let trendingCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	var trendingDatasource: UICollectionViewDiffableDataSource<TrendingSection, Trending>?
	var isShowingTrending: Bool = false
	let loadingView: UIView = UIView(frame: .zero)
	let loadingActivityActivator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
	var loadingViewTopConstraint: NSLayoutConstraint?
	var isShowingLoadingView: Bool = false
	let searchResultsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	var searchResultsDatasource: UICollectionViewDiffableDataSource<SectionPlaceHolder, ImagePlaceholder>?
	var isShowingSearchResults: Bool = false
	let networkManager: NetworkingManager = NetworkingManager.shared
		
	
	// MARK: view life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		configureSubviews()
		configureDatasource()
		
		// we are adding & fully configuring
		// each view as a subview to view
		configureTrendingCollectionView()
		configureLoadingViewAndIndicator()
		configureSearchResultsCollectionView()
		
		// TODO: remove this to unsilence constraint breaks from estimated cell heights
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		
		if !isShowingLoadingView {
			// show loadingView right away - no animationDuration
			animateLoadingView(forAppearance: true, withDuration: 0.0, fullScreen: true)
		}
		
		NetworkingManager.shared.dowloadHomeImagesListData { data, error in
			DispatchQueue.main.async {
				// print error & return
				if let error = error {
					print(error)
					return
				}
				
				// unpack data
				guard let _ = data else { return }

				// apply snapshot as the data
				// has been updated within NetworkManager
				self.applySnapshot()
				
				// successful so dismiss loading
				if self.isShowingLoadingView {
					self.animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration, fullScreen: true)
				}
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// add ourselves as keyboard notification observer
		if !isObservingKeyboard {
			NotificationCenter.default.addObserver(self,
																						 selector: #selector(keyboardWillShow(notification:)),
																						 name: UIResponder.keyboardWillShowNotification,
																						 object: nil)
			NotificationCenter.default.addObserver(self,
																						 selector: #selector(keyboardWillHide(notification:)),
																						 name: UIResponder.keyboardWillHideNotification,
																						 object: nil)
			isObservingKeyboard = true
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// we know our loginView will have size by now
		adjustLoginViewPositionForAppearance()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// remove ourselves as observer
		if isObservingKeyboard {
			NotificationCenter.default.removeObserver(self)
			isObservingKeyboard = false
		}
	}
			
	
	// MARK: subviews config
	
	private func configureSubviews() {
		// inset content by our scrollingNavView height
		collectionView.contentInset = UIEdgeInsets(top: Self.navMaxHeight, left: 0.0, bottom: 0.0, right: 0.0)
		collectionView.contentInsetAdjustmentBehavior = .never // by default, behavior adjusts inset 20 pts for status bar
		collectionView.scrollsToTop = true // ensure value is true
		collectionView.showsVerticalScrollIndicator = false
		collectionView.scrollsToTop = false // will implement our custom scrollsToTop behavior
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
	
	func didPressCancelButton(_ sender: UIButton, withFirstResponder firstResponder: UIView?) {
		// passing first responder through so view controller
		// can time dismissing of first responder with login
		// view dismiss - but as of now, we're just dismissing
		// them at same time
		if isShowingLoginView, let firstResponder = firstResponder {
			firstResponder.endEditing(true) // dismiss keyboard
		}
		
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
	
	private func animateLoginView(forKeyboardHeight keyboardHeight: CGFloat) {
		let viewMidYConstant = (view.bounds.size.height / 2.0) - (loginView.bounds.size.height / 2.0)
		
		// make sure loginView is located where we set it at in animateLoginViewAppearance()
		guard loginViewBottomConstraint?.constant == viewMidYConstant else { return }
		
		// subtracting a bit from keyboardHeight so there's a bit of overlap
		loginViewBottomConstraint?.constant = keyboardHeight - 20.0
		
		// duration doesn't matter here because any animations that occur during
		// keyboard appearance last for the same duration as the keyboard appearing
		// even if I try to modify the duration - check the keyboard notification
		// method notes
		UIView.animate(withDuration: 0.3,
									 delay: 0.0, options: .curveEaseInOut, animations: {
										self.view.layoutIfNeeded()
									 }, completion: nil)
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


	
// MARK: scrollNavView/search button actions/delegate methods

extension HomeViewController: ScrollingNavigationButtonsProvider {
	
	func didPressMenuButton(_ button: UIButton) {
		// present fresh instance of menu VC modally via sheet
		present(MenuViewController(), animated: true, completion: nil)
	}
	
	func didPressLogInButton(_ button: UIButton) {
		animateLoginViewAppearance()
	}
	
	// we begin our search flow here by showing our trendingCollectionView
	func didBeginEditingSearchBar(_ searchBar: UISearchBar) {
		let offset = -collectionView.contentOffset.y
		
		// only snap if within the money zone $$
		if offset <= Self.navMaxHeight && offset > Self.navMinHeight {
			snapScrollViewContentToTop(collectionView, withDuration: Self.trendingAnimationDuration)
		}
		
		animateTrendingCollectionView(forAppearance: true, withDuration: Self.trendingAnimationDuration)
	}
	
	func didSearch(withTerm term: String, andFirstResponder firstResponder: UIView) {
		firstResponder.resignFirstResponder()
		
		// do any loading here before presenting the searchResultsCollectionView
		
//		animateLoadingView(forAppearance: true, withDuration: Self.trendingAnimationDuration)
				
		animateSearchResultsCollectionView(forAppearance: true,
																			 withDuration: Self.trendingAnimationDuration) { [weak self] in
			guard let self = self else { return }
			
			if self.isShowingLoadingView {
				self.animateLoadingView(forAppearance: false) // dismiss loading view
			}
		}
		
		print("term: \(term)")
	}
	
	// pass first responder so view controller
	// can time dismissing of first responder
	// with any other animations - but we're
	// not doing much here
	func didPressSearchCancelButton(withFirstResponder firstResponder: UIView) {
		firstResponder.resignFirstResponder() // resign first responder
		
		// dismiss trending collectionView if showing
		if isShowingTrending {
			animateTrendingCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
		
		// dismiss loadingView if showing
		if isShowingLoadingView {
			animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
		
		// dismiss searchResults if showing
		if isShowingSearchResults {
			animateSearchResultsCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
	}
	
	// when user clicks "x" within search bar and there is no first responder
	func didClearSearchWithNoFirstResponder() {
		// dismiss loading view if showing
		if isShowingLoadingView {
			animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
		
		// dismiss searchResults if showing
		if isShowingSearchResults {
			animateSearchResultsCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
	}
	
}



// MARK: compositional layout

extension HomeViewController {
	
	private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			let currentSectionType = self.networkManager.homeImagesSections[sectionIndex].type

			switch currentSectionType {
			case .explore:
				let section = self.sectionLayoutForHomeOrthogonalCell()
				self.createSectionHeaderLayout(forSection: section)
				return section
			case .new:
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
	
	func sectionLayoutForHomeImageCell() -> NSCollectionLayoutSection {
		// will return back to estimated shortly for both itemSize & groupSize
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
			[weak self] (collectionView, indexPath, imagePlaceholder) -> UICollectionViewCell? in
			
			guard let self = self else { return nil }
			
			let currentSection = self.networkManager.homeImagesSections[indexPath.section]

			switch currentSection.type {
			case .explore:
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeOrthogonalCell.reuseIdentifier,
																														for: indexPath) as? HomeOrthogonalCell else { return nil }
				
				return cell
			case .new:
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeImageCell.reuseIdentifier,
																														for: indexPath) as? HomeImageCell else { return nil }

				// get current photo
				let photo = currentSection.items[indexPath.row]
				
				// determine & set cell height from photo dimensions
				let cellWidth: CGFloat = collectionView.bounds.width
				let product = cellWidth * CGFloat(photo.height)
				let cellHeight: CGFloat = product / CGFloat(photo.width)
				cell.imageHeight = Int(cellHeight)
				
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
				reusableView.displayStyle = currentSection.type == .explore ? .large : .small
				return reusableView
			}
			
			return nil
		}
	}
	
	private func applySnapshot() {
		let homeSections = NetworkingManager.shared.homeImagesSections
		
		var snapshot = NSDiffableDataSourceSnapshot<PhotoSection, Photo>()
		snapshot.appendSections(homeSections)
		homeSections.forEach { section in
			snapshot.appendItems(section.items, toSection: section)
		}
		
		// a small workaround to fix the layout of the orthogonal section
		// of cells - the second application of snapshot correctly places
		// the cells without affecting the UI
		datasource.apply(snapshot, animatingDifferences: true) {
			self.datasource.apply(snapshot, animatingDifferences: false)
		}
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
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		// get section & photo for indexPath
		let section = self.networkManager.homeImagesSections[indexPath.section]
		let photo = section.items[indexPath.row]

		switch section.type {
		case .explore:
			
			// reset image
			guard let exploreCell = cell as? HomeOrthogonalCell else { return }
			exploreCell.displayImage = nil
			
			// show loading if no blurred image to show
			exploreCell.isLoading = true
			
			// "fetch" blurred image from NetworkManager
			NetworkingManager.shared.processBlurredImage(usingBlurHashString: photo.blurString) { blurredImage in
				DispatchQueue.main.async {
					guard let exploreSectionCell = collectionView.cellForItem(at: indexPath) as? HomeOrthogonalCell else { return }
					exploreCell.isLoading = false
					exploreSectionCell.displayImage = blurredImage
				}
			}
		case .new:
			// reset image
			guard let newCell = cell as? HomeImageCell else { return }
			newCell.displayImage = nil
			
			// show loading if no blurred image to show
			newCell.isLoading = true
			
			// "fetch" blurred image from NetworkManager
			NetworkingManager.shared.processBlurredImage(usingBlurHashString: photo.blurString) { blurredImage in
				DispatchQueue.main.async {
					guard let newSectionCell = collectionView.cellForItem(at: indexPath) as? HomeImageCell else { return }
					newSectionCell.isLoading = false
					newSectionCell.displayImage = blurredImage
				}
			}
		}
		
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
		
		
		// logic to handle setting of scrollingNavView frame
		
		// set restriction on min height for scrollingNavView
		let height: CGFloat = max(offset, Self.navMinHeight)
		
		// update frames
		var scrollNavViewFrame: CGRect = scrollingNavView.frame
		scrollNavViewFrame.size.height = height
		scrollingNavView.frame = scrollNavViewFrame
		
		
		// logic to handle setting alphas on scrollingNavView subviews
		
		if offset < Self.navMaxHeight && offset > Self.navMinHeight {
			let desiredScrollRange: CGFloat = Self.navMaxHeight - Self.navMinHeight // represents old number
			let absoluteHeight = abs(height - Self.navMaxHeight) // represents new number
			let difference = desiredScrollRange - absoluteHeight
			let percentDifference = difference / desiredScrollRange
			scrollingNavView.animateSubviews(forScrollDelta: percentDifference)
		} else if offset <= Self.navMinHeight {
			scrollingNavView.animateSubviews(forScrollDelta: 0.0)
		} else if offset >= Self.navMaxHeight {
			scrollingNavView.animateSubviews(forScrollDelta: 1.0)
		}
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
			snapScrollViewContentToTop(scrollView, withDuration: 0.3)
		}
	}
	
	// allow passing of duration so we can
	// time this animation with other ones
	private func snapScrollViewContentToTop(_ scrollView: UIScrollView, withDuration duration: TimeInterval = 0.03) {
		UIView.animate(withDuration: duration,
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

// currently we only expect to see the keyboard in 2 cases
// 1 - When user clicks on search bar in scrollingNavView
// 2 - When user clicks in textField within LoginView

extension HomeViewController {
	
	// OJO!!
	
	// DO NOT call any animation code within these keyboard notification
	// methods unless you're fine with the keyboard animation duration
	// overriding any of your custom animations... this happens by defaut,
	// as these keyboard methods are called within an animation block called
	// by the system, so in order to override this, just call your code in
	// the code that triggers these methods.. for example
	
	// if pressing a cancel button dismisses the keyboard, call the animation
	// code in the cancel button action code, not in keyboardWillHide(notification:) method
	
	// in order to prevent our animations from being overriden, we keep any
	// code within these methods to a minimum and handle as much outside of
	// these methods as possible
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if isShowingLoginView {
			// unpack keyboard height
			guard let userInfoDict = notification.userInfo,
						let keyboardHeightNSValue = userInfoDict[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
			
			let keyboardHeight = keyboardHeightNSValue.cgRectValue.height
			
			animateLoginView(forKeyboardHeight: keyboardHeight)
		}
		
		scrollingNavView.setShowsCancelButton(shows: true, animated: true)
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		scrollingNavView.setShowsCancelButton(shows: false, animated: true)
	}
	
}
