//
//  XCTestCase+ProductStoreSpecs.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import XCTest
import EssentialProducts

extension ProductStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(_ cache: (products: [LocalProductItem], timestamp: Date), to sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let exp = expectation(description: "Wait for completion")
        
        var insertionError: Error?
        sut.insert(cache.products, timestamp: cache.timestamp) { receivedInsertionError in
            XCTAssertNil(insertionError, "Expected products to be inserted successfully", file: file, line: line)
            exp.fulfill()
            insertionError = receivedInsertionError
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let exp = expectation(description: "Wait for completion")
        var deletionError: Error?
        sut.deleteCachedProducts { receivedDeletionError in
            exp.fulfill()
            deletionError = receivedDeletionError
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: ProductStore, toRetrieve expectedResult: RetrievalCachedProductResult, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve { retrievedResult in
            
            switch(expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
            case let (.found(expected, expectedTimestamp), .found(retrieved, retrievedTimestamp)):
                XCTAssertEqual(expected, retrieved, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
        
            default: XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: ProductStore, toRetrieveTwice expectedResult: RetrievalCachedProductResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
}
