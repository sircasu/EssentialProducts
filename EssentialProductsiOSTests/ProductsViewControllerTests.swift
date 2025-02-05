//
//  ProductsViewControllerTests.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 05/02/25.
//

import XCTest
import UIKit
import EssentialProducts

final class ProductsViewController: UIViewController {
    
    private var loader: ProductsLoader?
    
    convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
}

final class ProductsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadProducts() {
        
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_viewDidLoad_loadProducts() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.callCount, 1)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: ProductsLoader {
        
        var callCount = 0
        
        func load(completion: @escaping (ProductsLoader.Result) -> Void) {
            callCount += 1
        }
    }
}
