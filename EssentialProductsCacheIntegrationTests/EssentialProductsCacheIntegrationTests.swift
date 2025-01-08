//
//  EssentialProductsCacheIntegrationTests.swift
//  EssentialProductsCacheIntegrationTests
//
//  Created by Matteo Casu on 08/01/25.
//

import XCTest
import EssentialProducts

final class EssentialProductsCacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            
            switch result {
            case let .success(products):
                XCTAssertEqual(products, [])
            case let .failure(error):
                XCTFail("Expected success got \(error) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectoryURL().appendingPathComponent("\(type(of: self)).store)")
    }
    
    private func cachesDirectoryURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
