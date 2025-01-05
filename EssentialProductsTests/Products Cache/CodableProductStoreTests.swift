//
//  CodableProductStoreTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 16/12/24.
//

import XCTest
import EssentialProducts

final class CodableProductStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .found(products, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(products, timestamp))
    }
    
    func test_retrieve_deliversErrorOnInvalidData() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((products, timestamp: timestamp), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        
        let latestProducts = uniqueItems2().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestProducts, timestamp: latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesExistingCache() {
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        insert((products, timestamp: timestamp), to: sut)

        
        let latestProducts = uniqueItems2().local
        let latestTimestamp = Date()
        insert((latestProducts, timestamp: latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(latestProducts, latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStore = URL(string: "invalid:/store-url")
        let sut = makeSUT(storeURL: invalidStore)
        let products = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((products, timestamp: timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStore = URL(string: "invalid:/store-url")
        let sut = makeSUT(storeURL: invalidStore)
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        
        let deletionError =  deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_leavesCacheEmptyOnNonEmptyCache() {
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
        
    func test_delete_hasNoSideEffectOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
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
        XCTAssertEqual(completedOperation, [op1, op2, op3], "Expected store side-effects to run serially but operation finished in wrong order")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> ProductStore {
        let sut = CodableProductStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (products: [LocalProductItem], timestamp: Date), to sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
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
    
    private func expect(_ sut: ProductStore, toRetrieve expectedResult: RetrievalCachedProductResult, file: StaticString = #filePath, line: UInt = #line) {

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
    
    private func expect(_ sut: ProductStore, toRetrieveTwice expectedResult: RetrievalCachedProductResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
