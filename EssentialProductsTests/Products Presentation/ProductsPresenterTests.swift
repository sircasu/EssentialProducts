//
//  ProductsPresenterTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 19/03/25.
//

import XCTest

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
    
    var productsErrorView: ProductsErrorView
    
    init(productsErrorView: ProductsErrorView) {
        self.productsErrorView = productsErrorView
    }
    
    func didStartLoadingProducts() {
        productsErrorView.display(.noError)
    }
}

final class ProductsPresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages on init")
    }
    
    func test_didStartLoadingProducts_displayNoErrorMessages() {
        
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingProducts()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(productsErrorView: view)
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: ProductsErrorView {

        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: ProductsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
