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
        
        sut.simulateAppareance()
        
        XCTAssertEqual(loader.loadProductCallCount, 1, "Expected q loading requests once view is appeared")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.loadProductCallCount, 2, "Expected another loading requests once user initiates reload")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.loadProductCallCount, 3, "Expected a third loading requests once user initiates another reload")
    }
    
    func test_loadProductIndicator_isVisibleWhenLoadingProducts() {
        let (sut, loader) = makeSUT()

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
        
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL request until image is not visible")
        
        sut.simulateProductImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image], "Expected one cancelled image URL request once first image becomes not visible anymore")
        
        sut.simulateProductImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image, product1.image], "Expected two cancelled image URL requests once second image becomes not visible anymore")
    }
    
    func test_productImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let product0 = makeProduct()
        let product1 = makeProduct()
        
        let (sut, loader) = makeSUT()
        
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
        
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        
        let view0 = sut.simulateProductImageViewVisible(at: 0)
        let view1 = sut.simulateProductImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first view loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry acion state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected  retry action for second view once second image loading completes with error")
    }
    
    func test_productImageViewRetryButton_isVisibleOnInvalidImageData() {
        let product0 = makeProduct()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0])
        
        let view0 = sut.simulateProductImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expected retry action once image loading complete with invalid image data")
    }
    
    func test_productImageViewRetryButton_retriesImageLoad() {
        let product0 = makeProduct()
        let product1 = makeProduct()
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        
        let view0 = sut.simulateProductImageViewVisible(at: 0)
        let view1 = sut.simulateProductImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected two image URL requests for the two visivble views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected only two image URL request before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image, product0.image], "Expected third URL request after first retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image, product0.image, product1.image], "Expected fourth image URL request after second retry action")
    }
    
    func test_productImageView_preloadsImageURLWhenNearVisible() {
        let product0 = makeProduct()
        let product1 = makeProduct()

        let (sut, loader) = makeSUT()
        
        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL request until image is near visible")
        
        sut.simulateProductImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image], "Expected first image URL request once first image is near visible")
        
        sut.simulateProductImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [product0.image, product1.image], "Expected second image URL request once second image is near visible")
    }
        
    func test_productImageView_cancelPreloadsImageURLWhenNotNearVisibleAnymore() {
        let product0 = makeProduct()
        let product1 = makeProduct()

        let (sut, loader) = makeSUT()

        sut.simulateAppareance()
        
        loader.completeProductsLoading(with: [product0, product1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL request until image is not near visible")
        
        sut.simulateProductImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateProductImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [product0.image, product1.image], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ProductsUIComposer.productsComposedWith(productsLoader: loader, imageLoader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeProduct(id: Int = 0, title: String = "title", price: Double = 4.99, description: String = "description", category: String = "category", image: URL = URL(string: "https://any-url.com")!, ratingAvarage: Double = 4.99, ratingCount: Int = 18) -> ProductItem {
        
        return ProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: ProductRatingItem(rate: ratingAvarage, count: ratingCount))
    }

}

class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
