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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
    
}
