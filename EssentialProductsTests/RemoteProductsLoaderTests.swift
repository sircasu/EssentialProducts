//
//  RemoteProductsLoaderTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 01/11/24.
//

import XCTest

final class RemoteProductsLoader {
    
}

protocol HTTPClient {
    func get()
}

final class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get() {
        
    }
}

final class RemoteProductsLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
    
        let client = HTTPClientSpy()
        
        let sut = RemoteProductsLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
