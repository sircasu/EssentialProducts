//
//  CodableProductStoreTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 16/12/24.
//

import XCTest
import EssentialProducts

class CodableProductStore {
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("products.store")
    
    private struct Cache: Codable {
        let products: [LocalProductItem]
        let timestamp: Date
    }

    func retrieve(completion: @escaping ProductStore.RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(cache.products, cache.timestamp))
    }
    
    func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping ProductStore.InsertionCompletion) {
        
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(products: items, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
    
}

final class CodableProductStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("products.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("products.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = CodableProductStore()
        
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { result in
            
            switch result {
            case .empty: break
            default: XCTFail("Expected empty result got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = CodableProductStore()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve { firstResult in
            
            sut.retrieve { secondResult in
                
                switch (firstResult, secondResult) {
                    case (.empty, .empty): break
                default: XCTFail("Expected empty results got \(firstResult) and \(secondResult) instead")
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsert_deliversInsertedValues() {
        
        let sut = CodableProductStore()
        
        let products = uniqueItems().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.insert(products, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected products to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                
                switch retrieveResult {
                case let .found(retrievedProducts, retrievedTimestamp):
                    XCTAssertEqual(retrievedProducts, products)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default: XCTFail("Expected result with products \(products) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
            }
            
            exp.fulfill()
            
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
