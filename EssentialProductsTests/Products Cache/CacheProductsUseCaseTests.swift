//
//  CacheProductsUseCaseTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 22/11/24.
//

import XCTest


class LocalProductsLoader {
    init(store: ProductStore) {}
}

class ProductStore {
    
    var deleteCallCount = 0
}


final class CacheProductsUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestToDeleteCache() {
    
        let store = ProductStore()
        let sut = LocalProductsLoader(store: store)
        
        XCTAssertEqual(store.deleteCallCount, 0)
    }
}
