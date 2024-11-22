//
//  CacheProductsUseCaseTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 22/11/24.
//

import XCTest


class LocalProductsLoader {
    
    let store: ProductStore
    
    init(store: ProductStore) {
        self.store = store
    }
    
    func save() {
        store.delete()
    }
}

class ProductStore {
    
    var deleteCallCount = 0
    
    func delete() {
        deleteCallCount += 1
    }
}


final class CacheProductsUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestToDeleteCache() {
    
        let store = ProductStore()
        let _ = LocalProductsLoader(store: store)
        
        XCTAssertEqual(store.deleteCallCount, 0)
    }
    
    func test_save_requestToDeleteCache() {
        
        let store = ProductStore()
        let sut = LocalProductsLoader(store: store)
    
        sut.save()
        
        XCTAssertEqual(store.deleteCallCount, 1)
    }

}
