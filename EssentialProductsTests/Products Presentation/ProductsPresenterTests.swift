//
//  ProductsPresenterTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 19/03/25.
//

import XCTest

final class ProductsPresenter {
    init(view: Any) {

    }
}

final class ProductsPresenterTests: XCTestCase {
    
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages on init")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsPresenter, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = ProductsPresenter(view: view)
        trackForMemoryLeak(view, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        
        let messages = [Any]()
    }
}
