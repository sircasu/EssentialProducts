//
//  CacheProductsUseCaseTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 22/11/24.
//

import XCTest
import EssentialProducts

class LocalProductsLoader {
    
    let store: ProductStore
    
    init(store: ProductStore) {
        self.store = store
    }
    
    func save(_ items: [ProductItem]) {
        store.delete() { [weak self] error in
            if error == nil {
                self?.store.insert(items)
            }
        }
    }
}

class ProductStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    private var deletionCompletions: [DeletionCompletion] = [DeletionCompletion]()
    
    var deleteCallCount = 0
    var insertCallCount = 0
    
    func delete(completion: @escaping DeletionCompletion) {
        deleteCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insert(_ items: [ProductItem]) {
        insertCallCount += 1
    }
    
    func completeWithError(error: Error?, at index: Int = 0) {
        
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}


final class CacheProductsUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestToDeleteCache() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCallCount, 0)
    }
    
    func test_save_requestToDeleteCache() {
        
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(id: 1)])
        
        XCTAssertEqual(store.deleteCallCount, 1)
    }
    
    func test_save_doesNotRequestToSaveCacheOnDeletionError() {
        
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(id: 1)])
        store.completeWithError(error: anyNSError())
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_doesRequestToSaveCacheOnDeletionSuccess() {
        
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(id: 1), uniqueItem(id: 2)])
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
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
    
    private func anyURL() -> URL {
        return URL(string: "https://example.com/")!
    }
    
    private func uniqueItem(id: Int) -> ProductItem {
        return ProductItem(id: 1, title: "any title", price: 12.99, description: "a description", category: "a category", image: anyURL(), rating: ProductRatingItem(rate: 4.3, count: 24))
    }
}
