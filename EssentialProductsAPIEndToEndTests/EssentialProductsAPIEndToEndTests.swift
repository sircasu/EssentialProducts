//
//  EssentialProductsAPIEndToEndTests.swift
//  EssentialProductsAPIEndToEndTests
//
//  Created by Matteo Casu on 09/11/24.
//

import XCTest
import EssentialProducts

final class EssentialProductsAPIEndToEndTests: XCTestCase {

    func test_endToEndServerGETProducts_matchesFixedTestData() {
        
        let client = URLSessionHTTPClient()
        let url = URL(string: "https://fakestoreapi.com/products?limit=3")!
        let loader = RemoteProductsLoader(client: client, url: url)
        
        let exp = expectation(description: "Wait for loading completion")
        loader.load { result in
            
            switch result {
            case let .success(products):
                XCTAssertEqual(products.count, 3, "Expected 3 products, got \(products.count) instead")
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3)
    }

}
