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
    let currentDate: () -> Date
    
    init(store: ProductStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [ProductItem], completion: @escaping (Error?) -> Void) {
        store.delete() { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            } else {
                completion(error)
            }
        }
    }
}

class ProductStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    enum ReceivedMessages: Equatable {
        case deleteCachedProducts
        case insert([ProductItem], Date)
    }
    
    var insertions = [(items: [ProductItem], timestamp: Date)]()
    var receivedMessages: [ReceivedMessages] = [ReceivedMessages]()
    
    var deletionCompletions: [DeletionCompletion] = [DeletionCompletion]()
    
    func delete(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedProducts)
    }
    
    func insert(_ items: [ProductItem], timestamp: Date) {
        insertions.append((items, timestamp))
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeWithError(error: Error?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}


final class CacheProductsUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestToDeleteCache() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestToDeleteCache() {
        
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(id: 1)]) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedProducts])
    }
    
    func test_save_doesNotRequestToSaveCacheOnDeletionError() {
        
        let (sut, store) = makeSUT()
        let items = [uniqueItem(id: 1), uniqueItem(id: 2)]
        
        sut.save(items) { _ in }
        store.completeWithError(error: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedProducts])
    }
    
    func test_save_doesRequestToSaveCacheWithTimestampOnDeletionSuccess() {
        
        let timestamp = Date.init()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(id: 1), uniqueItem(id: 2)]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
      
        XCTAssertEqual(store.receivedMessages, [.deleteCachedProducts, .insert(items, timestamp)])
    }
        
    func test_save_deliverErrorOnDeletingError() {
        
        let (sut, store) = makeSUT()
        let items = [uniqueItem(id: 1), uniqueItem(id: 2)]
        let error = anyNSError()
        
        let exp = expectation(description: "Waid for load completion")
        var receivedError: Error?
        sut.save(items) {
            receivedError = $0
            exp.fulfill()
        }
        store.completeWithError(error: error)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStore) {
        let store = ProductStore()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
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
