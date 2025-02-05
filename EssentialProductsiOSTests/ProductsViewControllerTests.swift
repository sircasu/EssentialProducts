//
//  ProductsViewControllerTests.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 05/02/25.
//

import XCTest

final class ProductsViewController: UIViewController {
    
    private var loader: ProductsViewControllerTests.LoaderSpy?
    
    convenience init(loader: ProductsViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
}

final class ProductsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadProducts() {
        
        let loader = LoaderSpy()
        let _ = ProductsViewController(loader: loader)
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_viewDidLoad_loadProducts() {
        
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.callCount, 1)
    }
    
    class LoaderSpy {
        var callCount = 0
        
        func load() {
            callCount += 1
        }
    }
}
