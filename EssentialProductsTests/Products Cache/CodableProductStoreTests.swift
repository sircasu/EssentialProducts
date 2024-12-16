//
//  CodableProductStoreTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 16/12/24.
//

import XCTest
import EssentialProducts

class CodableProductStore {
    
    func retrieve(completion: @escaping ProductStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableProductStoreTests: XCTestCase {
    
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
    
}
