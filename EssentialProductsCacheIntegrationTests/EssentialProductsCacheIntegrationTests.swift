//
//  EssentialProductsCacheIntegrationTests.swift
//  EssentialProductsCacheIntegrationTests
//
//  Created by Matteo Casu on 08/01/25.
//

import XCTest
import EssentialProducts

final class EssentialProductsCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let products = uniqueItems().model
        
        expect(sutToPerformSave, toSave: products)
        expect(sutToPerformLoad, toLoad: products)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstProducts = uniqueItems().model
        let secondProducts = uniqueItems2().model
        
        expect(sutToPerformFirstSave, toSave: firstProducts)
        expect(sutToPerformSecondSave, toSave: secondProducts)
        expect(sutToPerformLoad, toLoad: secondProducts)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalProductsLoader {
        let storeBundle = Bundle(for: CoreDataProductStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataProductStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalProductsLoader(store: store, currentDate: Date.init)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalProductsLoader, toLoad expectedProducts: [ProductItem], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            
            switch result {
            case let .success(loadedProducts):
                XCTAssertEqual(loadedProducts, expectedProducts)
            case let .failure(error):
                XCTFail("Expected success got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalProductsLoader, toSave products: [ProductItem], file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for save completion")
        sut.save(products) { saveError in
            
            XCTAssertNil(saveError, "Expect to save products correctly")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectoryURL().appendingPathComponent("\(type(of: self)).store)")
    }
    
    private func cachesDirectoryURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
