//
//  CoreDataProductStoreTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import XCTest
import EssentialProducts

final class CoreDataProductStoreTests: XCTestCase, ProductStoreSpecs {
        
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesExistingCache() {
        let sut = makeSUT()
        assertThatInsertOverridesExistingCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_leavesCacheEmptyOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteLeavesCacheEmptyOnNonEmptyCache(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatStoresSideEffectsRunSerially(on: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ProductStore {
        let storeBundle = Bundle(for: CoreDataProductStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null") // `/dev/null` used to avoid sharing state with production (and other tests)
        let sut = try! CoreDataProductStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
}
