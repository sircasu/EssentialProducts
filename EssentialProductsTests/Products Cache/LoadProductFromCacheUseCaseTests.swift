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
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.load { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default: XCTFail("Expected error got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithError(error: expectedError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, expectedError)
    }
    
//    func test_load_deliversNotemsOnEmptyCache() {
//        
//        let (sut, store) = makeSUT()
//        let expectedError = anyNSError()
//        
//        let exp = expectation(description: "Wait for completion")
//        
//        var receivedError: Error?
//        sut.load { result in
//            receivedError = error
//            exp.fulfill()
//        }
//        
//        store.completeRetrievalWithError(error: expectedError)
//        
//        wait(for: [exp], timeout: 1.0)
//        
//        XCTAssertEqual(receivedError as? NSError, expectedError)
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStoreSpy) {
        let store = ProductStoreSpy()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
    
}
