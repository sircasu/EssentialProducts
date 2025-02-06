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
        
        XCTAssertEqual(loader.loadProductCallCount, 0, "Expected no loading requests before view is appearing")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        XCTAssertEqual(loader.loadProductCallCount, 1, "Expected q loading requests once view is appeared")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.loadProductCallCount, 2, "Expected another loading requests once user initiates reload")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.loadProductCallCount, 3, "Expected a third loading requests once user initiates another reload")
    }
    
    func test_loadProductIndicator_isVisibleWhenLoadingProducts() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        
        sut.simulateAppareance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initated reload")
        
        loader.completeProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initated reload is completed successfully")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initated reload for the second time")
        
        loader.completeProductLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initated second reload is completed with error")
    }
    
    func test_loadProductsCompletion_rendersSuccessfullyLoadedProducts() {
        let product0 = makeProduct(id: 0, title: "a title 0", price: 33.95, description: "a description 0", category: "a category 0", image: URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg")!, ratingAvarage: 3.3, ratingCount: 25)
                
        let product1 = makeProduct(id: 1, title: "a title 1", price: 23.95, description: "a description 1", category: "a category 1", image: URL(string: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg")!, ratingAvarage: 4.1, ratingCount: 46)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        assertThat(sut, isRendering: [])
        
        loader.completeProductsLoading(with: [product0], at: 0)
        assertThat(sut, isRendering: [product0])
    
        sut.simulateUserInitiatedProductsReload()
        loader.completeProductsLoading(with: [product0, product1], at: 0)
        assertThat(sut, isRendering: [product0, product1])
    }
    
    func test_loadProductsCompletion_doesNotAlterCurrentStateOnError() {
        let product0 = makeProduct()
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0], at: 0)
        assertThat(sut, isRendering: [product0])
        
        sut.simulateUserInitiatedProductsReload()
        loader.completeProductLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [product0])
    }
    
    func test_productImageView_loadImageURLWhenVisibile() {
        let product0 = makeProduct(image: URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg")!)
                
        let product1 = makeProduct(image: URL(string: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg")!)
        
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL request until view become visible")
        
        sut.simulateProductImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image], "Expected first image URL request once first view becomes visible")
        
        sut.simulateProductImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_productImageView_cancelLoadImageWhenImageViewIsNotVisibleAnymore() {
        let product0 = makeProduct(image: URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg")!)
                
        let product1 = makeProduct(image: URL(string: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg")!)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1], at: 0)
        
        XCTAssertEqual(loader.cancelledURLs, [], "Expected no cancelled image URL request until image is not visible")
        
        sut.simulateProductImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledURLs, [product0.image], "Expected one cancelled image URL request once first image becomes not visible anymore")
        
        sut.simulateProductImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [product0.image, product1.image], "Expected two cancelled image URL requests once second image becomes not visible anymore")
    }
    
    func test_productImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let product0 = makeProduct()
        let product1 = makeProduct()
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        
        let view0 = sut.simulateProductImageViewVisible(at: 0)
        let view1 = sut.simulateProductImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected no loading indicator state change for second view once first view loading completes successfully")        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_productImageView_rendersImageLoaadedFromURL() {
        let product0 = makeProduct()
        let product1 = makeProduct()
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        
        let view0 = sut.simulateProductImageViewVisible(at: 0)
        let view1 = sut.simulateProductImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected  image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected  no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected  image for second view once second image loading completes successfully")
    }
    
    func test_productImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let product0 = makeProduct()
        let product1 = makeProduct()
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        
        let view0 = sut.simulateProductImageViewVisible(at: 0)
        let view1 = sut.simulateProductImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first view loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry acion state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected  retry action for second view once second image loading completes with error")
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ProductsViewController(productsLoader: loader, imageLoader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ProductsViewController, isRendering products: [ProductItem], file: StaticString = #filePath, line: UInt = #line) {
        
        guard sut.numberOfRenderedProductViews() == products.count else {
            return XCTFail("Expected \(products.count) products, got \(sut.numberOfRenderedProductViews()) instead", file: file, line: line)
        }
        
        products.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
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
    
    private func makeProduct(id: Int = 0, title: String = "title", price: Double = 4.99, description: String = "description", category: String = "category", image: URL = URL(string: "https://any-url.com")!, ratingAvarage: Double = 4.99, ratingCount: Int = 18) -> ProductItem {
        
        return ProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: ProductRatingItem(rate: ratingAvarage, count: ratingCount))
    }
    
    class LoaderSpy: ProductsLoader, ProductImageDataLoader {
        
        // MARK: - ProductsLoader
        
        private var productsRequests: [(ProductsLoader.Result) -> Void] = [(ProductsLoader.Result) -> Void]()
                
        var loadProductCallCount: Int { productsRequests.count }
        
        func load(completion: @escaping (ProductsLoader.Result) -> Void) {
            productsRequests.append(completion)
        }
        
        func completeProductsLoading(with products: [ProductItem] = [], at index: Int = 0) {
            productsRequests[index](.success(products))
        }
        
        func completeProductLoadingWithError(_ error: Error = anyNSError(), at index: Int = 0) {
            productsRequests[index](.failure(error))
        }
        
        // MARK: - ProductImageDataLoader
        
        private struct TaskSpy: ProductImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var loadImageRequests = [(url: URL, completion: (ProductImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            loadImageRequests.map { $0.url }
        }
        
        private(set) var cancelledURLs: [URL] = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) -> ProductImageDataLoaderTask {
            loadImageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            loadImageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            loadImageRequests[index].completion(.failure(anyNSError()))
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
    
    @discardableResult
    func simulateProductImageViewVisible(at index: Int = 0) -> ProductItemCell? {
        return productView(at: index) as? ProductItemCell
    }
    
    func simulateProductImageViewNotVisible(at index: Int = 0) {
        let view = simulateProductImageViewVisible(at: index)
        
        let delegate = collectionView.delegate
        let indexPath = IndexPath(row: index, section: productsSection)
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)
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

    var isShowingLoadingIndicator: Bool {
        return productContainerImageView.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !productImageRetryButton.isHidden
    }
    
    var renderedImage: Data? {
        return productImageView.image?.pngData()
    }
    
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

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
