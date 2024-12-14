//
//  LoadProductFromCacheUseCaseTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 29/11/24.
//

import XCTest
import EssentialProducts

final class LoadProductFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_askForProductRetrieval() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(expectedError), when: {
            store.completeRetrievalWithError(error: expectedError)
        })
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyItems()
        })
    }
    
    func test_load_deliversCachedProductOnNonExpiredCache() {
        
        let fixedCurrentDate = Date()
        let products = uniqueItems()
        let nonExpiredTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT() { fixedCurrentDate }

        expect(sut, toCompleteWith: .success(products.model), when: {
            store.completeRetrieval(with: products.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_load_doesNotDeliverProductsOnCAcheExpiration() {
        
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusMaxCacheAge()
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: products.local, timestamp: expirationTimestamp)
        })
    }
        
    func test_load_doesNotDeliverProductsOnExpiredCache() {
        
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: -1)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: products.local, timestamp: expiredTimestamp)
        })
    }
    
    func test_load_hasNosideEffectsOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithError(error: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
        
    func test_load_hasNoSideEffectOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyItems()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() {
        
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusMaxCacheAge()
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: products.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteNonExpiredCache() {
        let fixedCurrentDate = Date()
        let products = uniqueItems()
        let nonExpiredTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: 1)
        let (sut, store) = makeSUT() { fixedCurrentDate }

        sut.load { _ in }
        
        store.completeRetrieval(with: products.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
        
    func test_load_hasNoSideEffectOnMoreExpiredCache() {
        
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusMaxCacheAge().adding(seconds: -1)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: products.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliversResultAfterSUTHasBeenDeallocated() {
        
        let store = ProductStoreSpy()
        var sut: LocalProductsLoader? = LocalProductsLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalProductsLoader.LoadResult]()
        sut?.load { receivedResult.append($0) }
        
        sut = nil
        
        store.completeRetrievalWithEmptyItems()
        
        XCTAssertTrue(receivedResult.isEmpty)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStoreSpy) {
        let store = ProductStoreSpy()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private func expect(_ sut: LocalProductsLoader, toCompleteWith expectedResult: LocalProductsLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedItems), .success(let expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default: XCTFail("Expected \(expectedResult) but received \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
