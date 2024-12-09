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
