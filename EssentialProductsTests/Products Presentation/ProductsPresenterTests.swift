//
//  ProductsPresenterTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 19/03/25.
//

import XCTest

protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

struct ProductsLoadingViewModel {
    let isLoading: Bool
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
    var productsErrorView: ProductsErrorView
    
    init(productsLoadingView: ProductsLoadingView, productsErrorView: ProductsErrorView) {
        self.productsLoadingView = productsLoadingView
        self.productsErrorView = productsErrorView
    }
    
    func didStartLoadingProducts() {
        productsErrorView.display(.noError)
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: true))
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(productsLoadingView: view, productsErrorView: view)
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: ProductsLoadingView, ProductsErrorView {
    
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: ProductsErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: ProductsLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
