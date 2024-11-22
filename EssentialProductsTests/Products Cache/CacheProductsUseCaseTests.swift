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
    var saveCallCount = 0
    
    func delete() {
        deleteCallCount += 1
    }
    
    func completeWithError(error: Error?, at index: Int = 0) {
        
    }
}


final class CacheProductsUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestToDeleteCache() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCallCount, 0)
    }
    
    func test_save_requestToDeleteCache() {
        
        let (sut, store) = makeSUT()
        
        sut.save()
        
        XCTAssertEqual(store.deleteCallCount, 1)
    }
    
    func test_save_doesNotRequestToSaveCacheOnDeletionError() {
        
        let (sut, store) = makeSUT()
        
        sut.save()
        store.completeWithError(error: anyNSError())
        
        XCTAssertEqual(store.saveCallCount, 0)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStore) {
        let store = ProductStore()
        let sut = LocalProductsLoader(store: store)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
    

}
