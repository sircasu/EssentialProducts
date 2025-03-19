//
//  ProductsPresenterTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 19/03/25.
//

import XCTest
import EssentialProducts

protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

struct ProductsLoadingViewModel {
    let isLoading: Bool
}



protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

struct ProductsViewModel {
    let products: [ProductItem]
}



struct ProductsErrorViewModel {
    var message: String?
    
    static var noError: ProductsErrorViewModel {
        return ProductsErrorViewModel(message: nil)
    }
}

protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}


final class ProductsPresenter {
    var productsLoadingView: ProductsLoadingView
    var productsView: ProductsView
    var productsErrorView: ProductsErrorView
    
    init(productsLoadingView: ProductsLoadingView, productsView: ProductsView, productsErrorView: ProductsErrorView) {
        self.productsLoadingView = productsLoadingView
        self.productsView = productsView
        self.productsErrorView = productsErrorView
    }
    
    func didStartLoadingProducts() {
        productsErrorView.display(.noError)
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingProducts(with products: [ProductItem]) {
        productsView.display(ProductsViewModel(products: products))
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: false))
    }
}

final class ProductsPresenterTests: XCTestCase {
    
    
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(productsLoadingView: view, productsView: view, productsErrorView: view)
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, view)
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
