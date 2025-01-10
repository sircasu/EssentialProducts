//
//  XCTestCase+ProductStoreSpecs.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import XCTest
import EssentialProducts

extension ProductStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
        
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .success(CachedProducts(products: products, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieveTwice: .success(CachedProducts(products: products, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        let products = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((products, timestamp: timestamp), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        
        let latestProducts = uniqueItems2().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestProducts, timestamp: latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesExistingCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        let products = uniqueItems().local
        let timestamp = Date()
        insert((products, timestamp: timestamp), to: sut)

        let latestProducts = uniqueItems2().local
        let latestTimestamp = Date()
        insert((latestProducts, timestamp: latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .success(CachedProducts(products: latestProducts, timestamp: latestTimestamp)), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
        
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        
        let deletionError =  deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }
    
    func assertThatDeleteLeavesCacheEmptyOnNonEmptyCache(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatStoresSideEffectsRunSerially(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        
        var completedOperation = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for op1")
        sut.insert(uniqueItems().local, timestamp: Date()) { _ in
            completedOperation.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for op2")
        sut.retrieve { _ in
            completedOperation.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for op3")
        sut.deleteCachedProducts { _ in
            completedOperation.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 1.0)
        XCTAssertEqual(completedOperation, [op1, op2, op3], "Expected store side-effects to run serially but operation finished in wrong order", file: file, line: line)
    }
}

extension ProductStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(_ cache: (products: [LocalProductItem], timestamp: Date), to sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let exp = expectation(description: "Wait for completion")
        
        var insertionError: Error?
        sut.insert(cache.products, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
            
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let exp = expectation(description: "Wait for completion")
        var deletionError: Error?
        sut.deleteCachedProducts { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: ProductStore, toRetrieve expectedResult: ProductStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve { retrievedResult in
            
            switch(expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break
            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(expected.products, retrieved.products, file: file, line: line)
                XCTAssertEqual(expected.timestamp, retrieved.timestamp, file: file, line: line)
        
            default: XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: ProductStore, toRetrieveTwice expectedResult: ProductStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
}
