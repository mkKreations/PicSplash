//
//  HomeViewController.swift
//  PicSplash
//
//  Created by Marcus on 2/6/21.
//

import UIKit

// TODO: REMOVE SAMPLE DATA
var showSampleData: Bool = false


final class HomeViewController: UIViewController {
	// class vars
	private static let navMaxHeight: CGFloat = 320.0
	static var navMinHeight: CGFloat {
		let safeAreaInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20.0
		return safeAreaInset + 50.0
	}
	private static let navSnapToTopBuffer: CGFloat = 162.0
	static let trendingAnimationDuration: TimeInterval = 0.4
	private static let searchResultsTopMargin: CGFloat = 100.0

	
	// instance vars
	private lazy var collectionView: UICollectionView = {
		UICollectionView(frame: view.frame, collectionViewLayout: configureCompositionalLayout())
	}()
	private var datasource: UICollectionViewDiffableDataSource<PhotoSection, AnyHashable>?
	private var sampleDatasource: UICollectionViewDiffableDataSource<SectionPlaceHolder, ImagePlaceholder>! // TODO: REMOVE SAMPLE DATA
	lazy var featuredView: FeaturedView = { // expose to public for view controller transition
		FeaturedView(frame: CGRect(origin: .zero,
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
	var trendingCollectionViewTopConstraint: NSLayoutConstraint?
	var trendingDatasource: UICollectionViewDiffableDataSource<TrendingSection, Trending>?
	var isShowingTrending: Bool = false
	let loadingView: UIView = UIView(frame: .zero)
	let loadingActivityActivator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
	var loadingViewTopConstraint: NSLayoutConstraint?
	var isShowingLoadingView: Bool = false
	let searchResultsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	var searchResultsCollectionViewTopConstraint: NSLayoutConstraint?
	var searchResultsDatasource: UICollectionViewDiffableDataSource<PhotoSectionType, Photo>?
	var sampleSearchResultsDatasource: UICollectionViewDiffableDataSource<SectionPlaceHolder, ImagePlaceholder>? // TODO: REMOVE SAMPLE DATA
	var isShowingSearchResults: Bool = false
	private(set) var isShowingKeyboard: Bool = false
	private let scrollToTopButton: DetailActionButton = DetailActionButton(detailAction: .scroll)
	private var isShowingScrollToTopButton: Bool = false
		
	
	// MARK: view life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		// TODO: REMOVE SAMPLE DATA
		if showSampleData {
			configureSubviews()
			configureDatasource()
			applyInitialSnapshot()
			return
		}
		
		configureSubviews()
		configureDatasource()
						
		// TODO: remove this to unsilence constraint breaks from estimated cell heights
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		
		// show loadingView right away - no animationDuration
		if !isShowingLoadingView {
			animateLoadingView(forAppearance: true, withDuration: 0.0, fullScreen: true)
		}
		
		NetworkingManager.shared.downloadHomeInitialData(withPhotoOfTheDayDimensions: CGSize(width: collectionView.bounds.width, height: Self.navMaxHeight),
																										 withPhotoOfTheDayScale: collectionView.traitCollection.displayScale) { error in
			DispatchQueue.main.async {
				// print error & return
				if let error = error {
					print(error)
					return
				}
				
				// set the photo of the day image
				self.setPhotoOfTheDayImage()
				
				// apply snapshot as the data
				// has been updated within NetworkManager
				self.applyInitialSnapshot()
				
				// successful so dismiss loading
				if self.isShowingLoadingView {
					// a little delay in dismissing loadingView
					// allows the collectionView to adjust the
					// second orthogonal cell - look at
					// applyInitialSnapshot() for more
					self.animateLoadingView(forAppearance: false,
																	withDuration: Self.trendingAnimationDuration,
																	withDelay: 0.5,
																	fullScreen: true)
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
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// update any view constraints that depend on the view's safeAreaEdgeInsets
		// the reason for this is because safeAreaEdgeInsets return 0 in viewDidLoad,
		// where we're currently doing all of our layout, so we capture any constraints
		// that depend on that value and update them appropriately here with the correct
		// value - all the values we're setting constraint constants to use the safeArea
		featuredView.updateConstraintsForSafeAreaEdgeInsets()
		trendingCollectionViewTopConstraint?.constant = Self.navMinHeight
		searchResultsCollectionViewTopConstraint?.constant = Self.navMinHeight
	}
	
	// MARK: subviews config
	
	private func configureSubviews() {
		// inset content by our scrollingNavView height
		collectionView.contentInset = UIEdgeInsets(top: Self.navMaxHeight, left: 0.0, bottom: 0.0, right: 0.0)
		collectionView.contentInsetAdjustmentBehavior = .never // by default, behavior adjusts inset 20 pts for status bar
		collectionView.showsVerticalScrollIndicator = false
		collectionView.prefetchDataSource = self // prefetching data to spread tasks out over cpus
		collectionView.scrollsToTop = false // will implement our custom scrollsToTop behavior
		collectionView.delegate = self
		collectionView.register(HomeOrthogonalCell.self, forCellWithReuseIdentifier: HomeOrthogonalCell.reuseIdentifier)
		collectionView.register(HomeImageCell.self, forCellWithReuseIdentifier: HomeImageCell.reuseIdentifier)
		collectionView.register(HomeCollectionReusableView.self,
														forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
														withReuseIdentifier: HomeCollectionReusableView.reuseIdentifier)
		view.addSubview(collectionView)
		
		featuredView.delegate = self // respond to button actions
		view.addSubview(featuredView) // add after collectionView so it's on top
		
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
		
		layoutLoginViewForInitialAppearance() // layout loginView
		
		// we are adding & fully configuring
		// each view as a subview to view
		// configuring these in an extension
		configureTrendingCollectionView()
		configureLoadingViewAndIndicator()
		configureSearchResultsCollectionView()
				
		// scroll to top button
		scrollToTopButton.frame = CGRect(x: view.bounds.width + DetailActionButton.buttonDimension, // right outside of view
																		 y: view.bounds.height - DetailActionButton.buttonDimension - 50.0,
																		 width: DetailActionButton.buttonDimension,
																		 height: DetailActionButton.buttonDimension)
		scrollToTopButton.isUserInteractionEnabled = false
		scrollToTopButton.delegate = self
		view.addSubview(scrollToTopButton)
	}
	
	private func setPhotoOfTheDayImage() {
		// make sure we have photo of the day
		guard let photoOfTheDay: Photo = NetworkingManager.shared.photoOfTheDay else { return }
		
		// attempt to set blurred image
		if let blurredImage = NetworkingManager.shared.cachedBlurredImage(forBlurHashString: photoOfTheDay.blurString) {
			featuredView.image = blurredImage
		}
		
		// attempt to set actual image
		if let image = NetworkingManager.shared.cachedImage(forImageUrlString: photoOfTheDay.imageUrl) {
			featuredView.image = image
		}
	}
	
	
	// MARK: helpers
	
	private func presentCancelAlert(withMessage message: String) {
		let alert = UIAlertController(title: "PicSplash", message: message, preferredStyle: .alert)
		alert.overrideUserInterfaceStyle = .dark
		let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alert.addAction(okAction)
		present(alert, animated: true, completion: nil)
	}
		
	
	// MARK: overrides
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
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
	
	private func animateLoginView(forKeyboardHeight keyboardHeight: CGFloat, willShow: Bool) {
		let viewMidXConstant: CGFloat = (view.bounds.size.height / 2.0) - (loginView.bounds.size.height / 2.0)
		let midXWithKeyboardHeight: CGFloat = keyboardHeight - 20.0 // subtracting a bit from keyboardHeight so there's a bit of overlap

		// set constant based on if keyboard will show or not
		loginViewBottomConstraint?.constant = willShow ? midXWithKeyboardHeight : viewMidXConstant
				
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

extension HomeViewController: FeaturedViewButtonsProvider {
	
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
		// TODO: REMOVE SAMPLE DATA
		if showSampleData {
			print("term: \(term)")

			firstResponder.resignFirstResponder() // resign first responder
			
			// make sure search collection isn't already/still showing
			// as well as scroll it to top for any following searches
			if isShowingSearchResults {
				animateSearchResultsCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration) {
					self.searchResultsCollectionView.setContentOffset(.zero, animated: false)
				}
			}
			
			// begin loading and perform search in completion -
			// this is to prevent case that time to fetch search
			// results takes less time than our animation
			if !isShowingLoadingView {
				animateLoadingView(forAppearance: true, withDuration: Self.trendingAnimationDuration) {
					sleep(1)
					
					// stop loading
					if self.isShowingLoadingView {
						self.animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
					}
					
					// if we have photos, show search results
					if !self.isShowingSearchResults {
						self.applySearchResultsSnapshot(animating: false) // apply snapshot, then show collectionView
						
						// show search results and animate in status bar
						self.animateSearchResultsCollectionView(forAppearance: true, withDuration: Self.trendingAnimationDuration) { [weak self] in
							guard let self = self else { return }
							self.animateScrollToTopButtonForSearchResultsCollectionView(self.searchResultsCollectionView)
						}
					}
					// TODO: SHOW NO SEARCH RESULTS STATE
					print("NO RESULTS")
				}
			}

			return
		}
		
		print("term: \(term)")

		firstResponder.resignFirstResponder() // resign first responder

		// if search results collection view is showing, we respect
		// our view structure to make animation appear smooth
		if isShowingSearchResults {
			// because of our view structure, animate loading appearearance
			// instantly and then animate search results away
			animateLoadingView(forAppearance: true, withDuration: 0.0) { [weak self] in
				guard let self = self else { return }

				// now that loading is showing, we can animate away
				// our search results and scroll it to top - after
				// scrolling to top, perform search
				self.animateSearchResultsCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration) {
					self.searchResultsCollectionView.setContentOffset(.zero, animated: false)
					
					// hide scroll to top button if showing
					// make sure to do this after manually
					// setting the collection view content offset
					if self.isShowingScrollToTopButton {
						self.animateScrollToTopButtonAppearance(forAppearance: false)
					}
					
					self.performSearch(withSearchTerm: term) // perform search
				}
			}
		}

		// when trending is the only view showing
		if !isShowingLoadingView && isShowingTrending {
			animateLoadingView(forAppearance: true, withDuration: Self.trendingAnimationDuration) { [weak self] in
				guard let self = self else { return }
				
				// make sure search results collection view is scrolled to top
				self.searchResultsCollectionView.setContentOffset(.zero, animated: false)
				
				// hide scroll to top button if showing
				// make sure to do this after manually
				// setting the collection view content offset
				if self.isShowingScrollToTopButton {
					self.animateScrollToTopButtonAppearance(forAppearance: false)
				}

				self.performSearch(withSearchTerm: term)
			}
		}
	}
	
	private func performSearch(withSearchTerm term: String) {
		// fetch search term results
		NetworkingManager.shared.search(withSearchTerm: term) { [weak self] (photos, searchTerm, error) in
			DispatchQueue.main.async {
				guard let self = self else { return }
				
				// stop loading, present error alert, & return
				if let error = error {
					// stop loading
					if self.isShowingLoadingView {
						self.animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
					}

					// present alert with message
					self.presentCancelAlert(withMessage: "Search error with term: \(searchTerm)\n\(error)")

					return // we're done here
				}
				
				if !photos.isEmpty { // if we have photos, show search results
					if !self.isShowingSearchResults {
						self.applySearchResultsSnapshot(animating: false) // apply snapshot immediately
						
						// due to our view hierarchy,
						// show search results with animation
						// and then hide loading view immediately
						self.animateSearchResultsCollectionView(forAppearance: true, withDuration: Self.trendingAnimationDuration) { [weak self] in
							guard let self = self else { return }
							
							if self.isShowingLoadingView {
								self.animateLoadingView(forAppearance: false, withDuration: 0.0)
							}
						}
					}
				} else {
					// stop loading
					if self.isShowingLoadingView {
						self.animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
					}

					// present alert with message
					self.presentCancelAlert(withMessage: "Sorry! No results found for \(searchTerm)")
				}
			}
		}
	}
	
	// pass first responder so view controller
	// can time dismissing of first responder
	// with any other animations - but we're
	// not doing much here
	func didPressSearchCancelButton(withFirstResponder firstResponder: UIView) {
		firstResponder.resignFirstResponder() // resign first responder
		
		// hide away scroll to top button
		if isShowingScrollToTopButton {
			animateScrollToTopButtonAppearance(forAppearance: false)
		}
		
		// dismiss trending collectionView if showing
		if isShowingTrending {
			// we're taking advantage of the fact that
			// trending collection view is always showing
			// during "search" flow, so when user presses
			// cancel, we check after we dismiss this view
			// to see if we should be showing the scroll to
			// to top button for the home collection view
			animateTrendingCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration) { [weak self] in
				guard let self = self else { return }
				
				// check if we should be presenting
				// scroll to top button now that
				// home collection view is showing
				if -(self.collectionView.contentOffset.y) < Self.navMinHeight {
					self.animateScrollToTopButtonAppearance(forAppearance: true)
				} else if -(self.collectionView.contentOffset.y) >= Self.navMaxHeight {
					self.animateScrollToTopButtonAppearance(forAppearance: false)
				}
			}
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
		// hide away scroll to top button
		if isShowingScrollToTopButton {
			animateScrollToTopButtonAppearance(forAppearance: false)
		}

		// dismiss loading view if showing
		if isShowingLoadingView {
			animateLoadingView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
		
		// dismiss searchResults if showing
		// and set contentOffset to 0 for any
		// following searches
		if isShowingSearchResults {
			animateSearchResultsCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
	}

	// when user clicks "x" within search bar and there is a first responder
	func didClearSearchWithFirstResponder(_ firstResponder: UIView) {
		// hide away scroll to top button
		if isShowingScrollToTopButton {
			animateScrollToTopButtonAppearance(forAppearance: false)
		}
		
		// animate away search results and
		// scroll it to top for "following" requests
		if isShowingSearchResults {
			animateSearchResultsCollectionView(forAppearance: false, withDuration: Self.trendingAnimationDuration)
		}
	}
	
}



// MARK: compositional layout

extension HomeViewController {
	
	private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
		let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
			let currentSectionType = NetworkingManager.shared.homeImagesSections[sectionIndex].type

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
		// TODO: REMOVE SAMPLE DATA
		if showSampleData {
			sampleDatasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
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
			return
		}
		
		datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
			[weak self] (collectionView, indexPath, imagePlaceholder) -> UICollectionViewCell? in
			
			guard let self = self else { return nil } // unpack self
						
			let currentSection = NetworkingManager.shared.homeImagesSections[indexPath.section]
			let homeImage = currentSection.items[indexPath.item]

			switch currentSection.type {
			case .explore:
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeOrthogonalCell.reuseIdentifier,
																														for: indexPath) as? HomeOrthogonalCell else { return nil }
								
				// set blurredImage
				cell.displayImage = NetworkingManager.shared.cachedBlurredImage(forBlurHashString: homeImage.blurHashString)

				// fetch & set actual image
				NetworkingManager.shared.downloadDownsampledImage(forImageUrlString: homeImage.imageUrlString,
																													forIndexPath: indexPath,
																													withImageDimensions: cell.bounds.size,
																													withImageScale: collectionView.traitCollection.displayScale) {
					(image, error, imageIndexPath) in
					DispatchQueue.main.async {
						guard let exploreSectionCell = collectionView.cellForItem(at: imageIndexPath) as? HomeOrthogonalCell else { return }
						exploreSectionCell.displayImage = image
					}
				}
				
				cell.displayText = homeImage.displayText

				return cell
			case .new:
				// get cell and photo
				guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeImageCell.reuseIdentifier,
																														for: indexPath) as? HomeImageCell else { return nil }
								
				// set blurredImage
				cell.displayImage = NetworkingManager.shared.cachedBlurredImage(forBlurHashString: homeImage.blurHashString)
				let cellHeight = self.calculateHomeImageHeight(forHomeImage: homeImage)

				// fetch & set actual image
				NetworkingManager.shared.downloadDownsampledImage(forImageUrlString: homeImage.imageUrlString,
																													forIndexPath: indexPath,
																													withImageDimensions: CGSize(width: collectionView.bounds.width, height: CGFloat(cellHeight)),
																													withImageScale: collectionView.traitCollection.displayScale) {
					(image, error, imageIndexPath) in
					DispatchQueue.main.async {
						guard let exploreSectionCell = collectionView.cellForItem(at: imageIndexPath) as? HomeImageCell else { return }
						exploreSectionCell.displayImage = image
					}
				}

				// determine & set cell height from photo dimensions
				cell.imageHeight = cellHeight
				cell.displayText = homeImage.displayText // set text
				
				return cell
			}
			
		})
		
		configureHomeReusableViewForDatasource()
	}
	
	private func configureHomeReusableViewForDatasource() {
		// TODO: REMOVE SAMPLE DATA
		if showSampleData {
			sampleDatasource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
				guard let self = self else { return nil }
			 
			 if kind == UICollectionView.elementKindSectionHeader {
				 
				 guard let currentSection = self.sampleDatasource?.snapshot().sectionIdentifiers[indexPath.section],
							 let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																																									withReuseIdentifier: HomeCollectionReusableView.reuseIdentifier,
																																									for: indexPath) as? HomeCollectionReusableView else { return nil }
				 reusableView.displayText = currentSection.title
				reusableView.displayStyle = currentSection.type == .orthogonal ? .large : .small
				 return reusableView
			 }
			 
			 return nil
		 }
			return
		}
		
		datasource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
			guard let self = self else { return nil }
			
			if kind == UICollectionView.elementKindSectionHeader {
				
				guard let currentSection = self.datasource?.snapshot().sectionIdentifiers[indexPath.section],
							let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																																								 withReuseIdentifier: HomeCollectionReusableView.reuseIdentifier,
																																								 for: indexPath) as? HomeCollectionReusableView else { return nil }
				reusableView.displayText = currentSection.title
				reusableView.displayStyle = currentSection.type == .explore ? .large : .small
				return reusableView
			}
			
			return nil
		}
	}
	
	private func applyInitialSnapshot() {
		// TODO: REMOVE SAMPLE DATA
		if showSampleData {
			var snapshot = NSDiffableDataSourceSnapshot<SectionPlaceHolder, ImagePlaceholder>()
			snapshot.appendSections(sampleData)
			sampleData.forEach { sampleSection in
				snapshot.appendItems(sampleSection.images, toSection: sampleSection)
			}
			sampleDatasource.apply(snapshot)
			return
		}
		
		let homeSections = NetworkingManager.shared.homeImagesSections
		
		var snapshot = NSDiffableDataSourceSnapshot<PhotoSection, AnyHashable>()
		snapshot.appendSections(homeSections)
		homeSections.forEach { section in
			switch section.type { // downcast since HomeImageProtocol doesn't inherit from Hashable
			case .explore:
				if let collections = section.items as? [Collection] {
					snapshot.appendItems(collections, toSection: section)
				}
			case .new:
				if let photos = section.items as? [Photo] {
					snapshot.appendItems(photos, toSection: section)
				}
			}
		}

		// applying a snapshot in the completion of another snapshot fixes
		// a layout issue within our orthogonal cell section that only shows
		// the first cell even though the section is groupPagingCentered so
		// really we should see one full cell and the leading edge of the second
		
		// all in all, we delay the dismissing of the loadingView so that the
		// user doesn't see any UI "jumps" - specifically the collectionView
		// forcing the correct placement of the second orthogoncal cell
		datasource?.apply(snapshot, animatingDifferences: true) {
			self.datasource?.apply(snapshot, animatingDifferences: false)
		}
	}
	
	// these photos can be huge so we make them proportional in size
	// to the collection view
	func calculateHomeImageHeight(forHomeImage homeImage: HomeImageProtocol) -> Int {
		let cellWidth: CGFloat = collectionView.bounds.width
		let product = cellWidth * CGFloat(homeImage.imageHeight)
		let cellHeight: CGFloat = product / CGFloat(homeImage.imageWidth)
		return Int(cellHeight)
	}

}



// MARK: collectionView delegate & prefetch methods

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			// TODO: REMOVE SAMPLE DATA
			if showSampleData { return }

			// get section & photo for indexPath
			let section = NetworkingManager.shared.homeImagesSections[indexPath.section]
			let homeImage = section.items[indexPath.row]

			// make size -
			// imageWidth for explore section is
			// rough estimate, not exact as it
			// doesn't factor in item content insets
			let imageHeight: CGFloat = section.type == .explore ? 140.0 : CGFloat(self.calculateHomeImageHeight(forHomeImage: homeImage))
			let imageWidth: CGFloat = section.type == .explore ? collectionView.bounds.width * 0.94 : collectionView.bounds.width
			let imageDimensions: CGSize = CGSize(width: imageWidth,
																					 height: imageHeight)

			// fetch & cache downsampled image
			NetworkingManager.shared.downloadDownsampledImage(forImageUrlString: homeImage.imageUrlString,
																												forIndexPath: indexPath,
																												withImageDimensions: imageDimensions,
																												withImageScale: collectionView.traitCollection.displayScale,
																												withCompletion: nil)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		// TODO: REMOVE SAMPLE DATA
		if showSampleData { return }
		
		indexPaths.forEach { indexPath in
			// get section & photo for indexPath
			let section = NetworkingManager.shared.homeImagesSections[indexPath.section]
			let homeImage = section.items[indexPath.row]

			// ensure we have valid url
			guard let imageUrl = URL(string: homeImage.imageUrlString) else { return }
			
			// cancel operation
			NetworkingManager.shared.cancelDownloadSampledImageOperation(forImageUrl: imageUrl)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// TODO: REMOVE SAMPLE DATA
		if showSampleData {
			let selectedSectionPlaceholder = sampleData[indexPath.section]
			
			// nothing to do for orthogonal cells for now
			if selectedSectionPlaceholder.type == .orthogonal { return }
			
			let selectedImagePlaceholder = selectedSectionPlaceholder.images[indexPath.row]
			// capture vars for view controller transition
			selectedCell = collectionView.cellForItem(at: indexPath) as? HomeImageCell
			selectedCellImageSnapshot = selectedCell?.displayImageView.snapshotView(afterScreenUpdates: false)
			
			let detailVC = DetailSampleViewController(imagePlaceholder: selectedImagePlaceholder)
			detailVC.transitioningDelegate = self
			detailVC.modalPresentationStyle = .fullScreen
			present(detailVC, animated: true, completion: nil)
			return
		}
		
		if collectionView == searchResultsCollectionView {
			// get our photo
			let photo = NetworkingManager.shared.searchResults.results[indexPath.row]

			// handle photo selection
			handleSelectedPhoto(photo, atIndexPath: indexPath, withCollectionView: collectionView)

			return
		}
		
		let homeSection = NetworkingManager.shared.homeImagesSections[indexPath.section]

		// nothing to do for explore section for now
		if homeSection.type == .explore { return }
				
		// get our photo
		guard let photo = homeSection.items[indexPath.row] as? Photo else { return }
		
		handleSelectedPhoto(photo, atIndexPath: indexPath, withCollectionView: collectionView)
	}
	
	private func handleSelectedPhoto(_ photo: Photo,
																	 atIndexPath indexPath: IndexPath,
																	 withCollectionView collectionView: UICollectionView) {
		// if the photo image has yet to load, do not
		// allow user to go to detail view controller
		guard let _ = NetworkingManager.shared.cachedImage(forImageUrlString: photo.imageUrl) else { return }

		// capture vars for view controller transition
		selectedCell = collectionView.cellForItem(at: indexPath) as? HomeImageCell
		selectedCellImageSnapshot = selectedCell?.displayImageView.snapshotView(afterScreenUpdates: false)

		// hide scroll to top button before presenting
		animateScrollToTopButtonFade(forPresenting: true)

		// present detail view controller
		presentDetailViewController(withPhoto: photo)
	}
		
	private func presentDetailViewController(withPhoto photo: Photo) {
		let detailVC = DetailViewController(photo: photo,
																				withCalculatedHeight: CGFloat(calculateHomeImageHeight(forHomeImage: photo)))
		detailVC.delegate = self
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
		
		let detailAnimator = HomeDetailAnimator(presentationType: .present,
																						homeViewController: homeViewController,
																						detailViewController: detailViewController,
																						selectedImageViewSnapshot: selectedCellImageSnapshot)
		return detailAnimator
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		// use default animation if we don't receive parameters
		guard let detailViewController = dismissed as? DetailViewController,
					let selectedCellImageSnapshot = selectedCellImageSnapshot else { return nil }
		
		let detailAnimator = HomeDetailAnimator(presentationType: .dismiss,
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
		self.animateScrollToTopButtonFade(forPresenting: false)
	}
	
	func didPressShareButton(_ sender: UIButton) {
		print("SHARE")
	}
	
}



// MARK: scrollview delegate & relevant methods

extension HomeViewController: DetailActionButtonsProvider {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// search results collection view logic
		animateScrollToTopButtonForSearchResultsCollectionView(scrollView)
		
		// only do this logic for our home collection view
		if scrollView != self.collectionView { return }
		
		// offset will begin as negative from origin since
		// we're using contentInsets on collectionView, so
		// we'll negate it to work with positive values
		let offset: CGFloat = -scrollView.contentOffset.y
		
		
		// logic to handle setting of scrollingNavView frame
		
		// set restriction on min height for scrollingNavView
		let height: CGFloat = max(offset, Self.navMinHeight)
		
		// update frames
		var scrollNavViewFrame: CGRect = featuredView.frame
		scrollNavViewFrame.size.height = height
		featuredView.frame = scrollNavViewFrame
		
		
		// logic to handle setting alphas on scrollingNavView subviews
		
		if offset < Self.navMaxHeight && offset > Self.navMinHeight {
			let desiredScrollRange: CGFloat = Self.navMaxHeight - Self.navMinHeight // represents old number
			let absoluteHeight = abs(height - Self.navMaxHeight) // represents new number
			let difference = desiredScrollRange - absoluteHeight
			let percentDifference = difference / desiredScrollRange
			featuredView.animateSubviews(forScrollDelta: percentDifference)
		} else if offset <= Self.navMinHeight {
			featuredView.animateSubviews(forScrollDelta: 0.0)
		} else if offset >= Self.navMaxHeight {
			featuredView.animateSubviews(forScrollDelta: 1.0)
		}
		
		
		// logic to scroll to top button showing/disappearing
		
		if offset < Self.navMinHeight {
			animateScrollToTopButtonAppearance(forAppearance: true)
		} else if offset >= Self.navMaxHeight {
			animateScrollToTopButtonAppearance(forAppearance: false)
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
		self.view.isUserInteractionEnabled = false // disable view interaction during animation
		
		UIView.animate(withDuration: duration,
									 delay: 0.0,
									 options: .curveEaseInOut) {
			// update contentOffset of collectionView
			scrollView.contentOffset = CGPoint(x: 0.0, y: -Self.navMinHeight)
			self.view.layoutIfNeeded() // force update view
		} completion: { _ in
			self.view.isUserInteractionEnabled = true // enable view interaction after
		}
	}
	
	@objc private func scrollToTopOnTap(_ tapGesture: UITapGestureRecognizer) {
		// detect which collectionView is
		// showing and handle accordingly
		if isShowingSearchResults {
			searchResultsCollectionView.setContentOffset(.zero, animated: true)
			return
		}
		
		// get offset
		let offset = -collectionView.contentOffset.y
		
		if offset < Self.navMinHeight {
			// our snapScrollViewContentToTop doesn't play
			// well here because calling view.layoutIfNeeded
			// while collectionView may be scrolling leads
			// to cells not being drawn/removed and other glitches
			collectionView.setContentOffset(CGPoint(x: 0.0, y: -Self.navMaxHeight), animated: true)
		}
	}
	
	private func animateScrollToTopButtonForSearchResultsCollectionView(_ scrollView: UIScrollView) {
		if scrollView == self.searchResultsCollectionView && self.isShowingSearchResults {
			if scrollView.contentOffset.y <= 0.0 {
				animateScrollToTopButtonAppearance(forAppearance: false)
			} else if scrollView.contentOffset.y > Self.searchResultsTopMargin {
				animateScrollToTopButtonAppearance(forAppearance: true)
			}
		}
	}
	
	private func animateScrollToTopButtonAppearance(forAppearance appearance: Bool,
																									withCompletion completion: (() -> ())? = nil) {
		if isShowingScrollToTopButton == appearance { return }
		
		// set initial states
		let isShowingOriginX: CGFloat = view.bounds.width - DetailActionButton.buttonDimension - 16.0
		let isHidingOriginX: CGFloat = view.bounds.width + DetailActionButton.buttonDimension
		let buttonOriginX: CGFloat = appearance ? isHidingOriginX : isShowingOriginX
		var buttonRect = CGRect(x: buttonOriginX,
														y: view.bounds.height - DetailActionButton.buttonDimension - 50.0,
														width: DetailActionButton.buttonDimension,
														height: DetailActionButton.buttonDimension)
		scrollToTopButton.frame = buttonRect
		scrollToTopButton.alpha = appearance ? 0.0 : 1.0
		
		// perform animations
		UIView.animateKeyframes(withDuration: Self.trendingAnimationDuration,
														delay: 0.0, options: .calculationModeCubic) {
			
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
				self.scrollToTopButton.alpha = appearance ? 1.0 : 0.0
			}

			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
				buttonRect.origin.x = appearance ? isShowingOriginX : isHidingOriginX
				self.scrollToTopButton.frame = buttonRect
			}

		} completion: { _ in
			// update user interaction for appearance
			self.scrollToTopButton.isUserInteractionEnabled = appearance
			
			// update our state for appearance
			self.isShowingScrollToTopButton = appearance
	
			completion?()
		}
	}
	
	// only use this method when presenting/dismissing a view controller
	// from the view controller that uses scroll to top button - in our
	// case, we're calling this method to fade in/out scrollToTop button
	// from home view controller when presenting/dismissing detail view controller
	private func animateScrollToTopButtonFade(forPresenting isPresenting: Bool) {
		scrollToTopButton.alpha = isPresenting ? 1.0 : 0.0
		
		UIView.animate(withDuration: 0.25) {
			self.scrollToTopButton.alpha = isPresenting ? 0.0 : 1.0
		}
	}
	
	func didPressDetailActionButton(_ detailAction: DetailAction) {
		if detailAction == .scroll {
			if isShowingSearchResults {
				searchResultsCollectionView.setContentOffset(.zero, animated: true)
			} else {
				collectionView.setContentOffset(CGPoint(x: 0.0, y: -Self.navMaxHeight), animated: true)
			}
		}
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
			
			animateLoginView(forKeyboardHeight: keyboardHeight, willShow: true)
		}
		
		featuredView.setShowsCancelButton(shows: true, animated: true)
		
		isShowingKeyboard = true
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		if isShowingLoginView {
			// unpack keyboard height
			guard let userInfoDict = notification.userInfo,
						let keyboardHeightNSValue = userInfoDict[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
			
			let keyboardHeight = keyboardHeightNSValue.cgRectValue.height
			
			animateLoginView(forKeyboardHeight: keyboardHeight, willShow: false)
		}
		
		featuredView.setShowsCancelButton(shows: false, animated: true)
		
		isShowingKeyboard = false
	}
	
}
