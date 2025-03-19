//
//  ProductsPresenterTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 19/03/25.
//

import XCTest
import EssentialProducts


final class ProductsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ProductsPresenter.title, localized("PRODUCTS_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages on init")
    }
    
    func test_didStartLoadingProducts_displayNoErrorMessagesAndStartLoading() {
        
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingProducts()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }
        
    func test_didFinishLoadingProducts_displayProductsAndStopLoading() {
        
        let (sut, view) = makeSUT()
        
        let products = uniqueItems().model
        sut.didFinishLoadingProducts(with: products)
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(products: products)
        ])
    }
    
    func test_didFinishLoadingProductsWithError_displayErrorAndStopLoading() {
        
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingProductsWithError()
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(errorMessage: localized("PRODUCTS_VIEW_CONNECTION_ERROR"))
        ])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(productsLoadingView: view, productsView: view, productsErrorView: view)
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, view)
    }
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        
        let table = "Products"
        let bundle = Bundle(for: ProductsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key:  \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: ProductsLoadingView, ProductsView, ProductsErrorView {
    
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(products: [ProductItem])
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: ProductsErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ProductsViewModel) {
             messages.insert(.display(products: viewModel.products))
        }
        
        
        func display(_ viewModel: ProductsLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
