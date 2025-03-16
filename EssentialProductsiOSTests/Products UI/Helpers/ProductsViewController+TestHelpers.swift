//
//  ProductsViewController+TestHelpers.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 06/02/25.
//

import UIKit
import EssentialProductsiOS

extension ProductsViewController {
    
    func simulateAppearance() {
        
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFake()
        }
        
        beginAppearanceTransition(true, animated: false) // viewWillAppear
        endAppearanceTransition() // viewIsAppearing + viewDidAppear
    }
    
    func replaceRefreshControlWithFake() {
        
        let fakeRefreshControl = FakeRefreshControl()

        collectionView?.refreshControl?.allTargets.forEach { target in
            collectionView?.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
            
            collectionView?.refreshControl = fakeRefreshControl
            refreshController?.view = fakeRefreshControl
        }

    }
    
    func simulateUserInitiatedProductsReload() {
        collectionView?.refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateProductImageViewVisible(at index: Int = 0) -> ProductItemCell? {
        return productView(at: index) as? ProductItemCell
    }
    
    @discardableResult
    func simulateProductImageViewNotVisible(at index: Int = 0) -> ProductItemCell? {
        let view = simulateProductImageViewVisible(at: index)
        
        let delegate = collectionView.delegate
        let indexPath = IndexPath(row: index, section: productsSection)
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)
        
        return view
    }
    
    func simulateProductImageViewNearVisible(at row: Int) {
        let dataSource = collectionView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: productsSection)
        dataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }
    
    func simulateProductImageViewNotNearVisible(at row: Int) {
        simulateProductImageViewNearVisible(at: row)
        
        let dataSource = collectionView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: productsSection)
        dataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
    }
    
    var errorView: ErrorHeaderView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? ErrorHeaderView

    }
    var errorMessage: String? {
        errorView?.message.text
    }
    
    var isShowingLoadingIndicator: Bool {
        return collectionView?.refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedProductViews() -> Int {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.numberOfItems(inSection: productsSection)
    }
    
    func productView(at row: Int) -> UICollectionViewCell? {

        let dataSource = collectionView.dataSource
        let indexPath = IndexPath(row: row, section: productsSection)
        return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    var productsSection: Int { 0 }
}
