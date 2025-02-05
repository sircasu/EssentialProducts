//
//  ProductsViewControllerTests.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 05/02/25.
//

import XCTest
import UIKit
import EssentialProducts
import EssentialProductsiOS

final class ProductsViewControllerTests: XCTestCase {

    func test_loadProductActions_requestProductsFromLoader() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0, "Expected no loading requests before view is appearing")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        XCTAssertEqual(loader.callCount, 1, "Expected q loading requests once view is appeared")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.callCount, 2, "Expected another loading requests once user initiates reload")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.callCount, 3, "Expected a third loading requests once user initiates another reload")
    }
    
    func test_loadProductIndicator_isVisibleWhenLoadingProducts() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        
        sut.simulateAppareance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once view loading is completed")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initated reload")
        
        loader.completeProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initated reload is complete")
    }
    
    func test_loadProductsCompletion_rendersSuccessfullyLoadedProducts() {
        let product0 = makeProduct(id: 0, title: "a title 0", price: 33.95, description: "a description 0", category: "a category 0", image: URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg")!, ratingAvarage: 3.3, ratingCount: 25)
                
        let product1 = makeProduct(id: 1, title: "a title 1", price: 23.95, description: "a description 1", category: "a category 1", image: URL(string: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg")!, ratingAvarage: 4.1, ratingCount: 46)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()

        XCTAssertEqual(sut.numberOfRenderedProductViews(), 0)
        
        loader.completeProductsLoading(with: [product0], at: 0)
        XCTAssertEqual(sut.numberOfRenderedProductViews(), 1)
        assertThat(sut, hasViewConfiguredFor: product0, at: 0)
    
        sut.simulateUserInitiatedProductsReload()
        loader.completeProductsLoading(with: [product0, product1], at: 0)
        
        assertThat(sut, hasViewConfiguredFor: product0, at: 0)
        assertThat(sut, hasViewConfiguredFor: product1, at: 1)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ProductsViewController, hasViewConfiguredFor product: ProductItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        let view = sut.productView(at: index)
        
        guard let cell = view as? ProductItemCell else {
            return XCTFail("Expected \(ProductItemCell.self), got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(cell.productName, product.title, "Expected product name to be \(String(describing: product.title)) for product view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.productDescription, product.description, "Expected product description to be \(String(describing: product.description)) for product view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.productPrice, String(product.price), "Expected product price to be \(String(describing: product.price)) for product view at index \(index)", file: file, line: line)
    }
    
    private func makeProduct(id: Int, title: String, price: Double, description: String, category: String, image: URL, ratingAvarage: Double, ratingCount: Int) -> ProductItem {
        
        return ProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: ProductRatingItem(rate: ratingAvarage, count: ratingCount))
    }
    
    class LoaderSpy: ProductsLoader {
        
        var messages: [(ProductsLoader.Result) -> Void] = [(ProductsLoader.Result) -> Void]()
        
        var callCount: Int { messages.count }
        
        func load(completion: @escaping (ProductsLoader.Result) -> Void) {
            messages.append(completion)
        }
        
        func completeProductsLoading(with products: [ProductItem] = [], at index: Int = 0) {
            messages[index](.success(products))
        }
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

private extension ProductsViewController {
    
    func simulateAppareance() {
        beginAppearanceTransition(true, animated: false) // viewWillAppear
        endAppearanceTransition() // viewIsAppearing + viewDidAppear
    }
    
    func replaceRefreshControlWithFake() {
        
        let fakeRefreshControl = FakeRefreshControl()
        
        fakeRefreshControl.simulatePullToRefresh()
        
        collectionView?.refreshControl = fakeRefreshControl
    }
    
    func simulateUserInitiatedProductsReload() {
        collectionView?.refreshControl?.simulatePullToRefresh()
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


private extension ProductItemCell {
    var productName: String? {
        productNameLabel.text
    }
    
    var productDescription: String? {
        productDescriptionLabel.text
    }
    
    var productPrice: String? {
        productPriceLabel.text
    }
}
