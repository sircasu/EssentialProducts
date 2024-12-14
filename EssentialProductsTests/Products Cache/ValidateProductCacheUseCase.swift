//
//  ValidatwProductCacheUseCase.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 09/12/24.
//

import XCTest
import EssentialProducts

final class ValidateProductCacheUseCase: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithError(error: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedProducts])
    }
    
    func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyItems()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheCacheExpiration() {
        
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusMaxCacheAge()
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: products.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedProducts])
    }
    
    func test_validateCache_doesNotDeleteOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let products = uniqueItems()
        let nonExpiredTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT() { fixedCurrentDate }

        sut.validateCache()
        
        store.completeRetrieval(with: products.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: -1)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: products.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedProducts])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTHasBeenDeallocated() {
        
        let store = ProductStoreSpy()
        var sut: LocalProductsLoader? = LocalProductsLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        
        store.completeRetrievalWithError(error: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStoreSpy) {
        let store = ProductStoreSpy()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }

}
