//
//  ProductsViewControllerTests.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 05/02/25.
//

import XCTest

final class ProductsViewController {
    
    init(loader: ProductsViewControllerTests.LoaderSpy) {}
}

final class ProductsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadProducts() {
        
        let loader = LoaderSpy()
        let _ = ProductsViewController(loader: loader)
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    
    class LoaderSpy {
        var callCount = 0
    }
}
