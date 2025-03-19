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
        let view = ViewSpy()
        
        _ = ProductsPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages on init")
    }
    
    
    // MARK: - Helpers
    
    private class ViewSpy {
        
        let messages = [Any]()
    }
}
