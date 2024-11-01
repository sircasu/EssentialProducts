//
//  RemoteProductsLoaderTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 01/11/24.
//

import XCTest

final class RemoteProductsLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    init(client: HTTPClient, url: URL = URL(string: "https://example.com/products")!) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from: URL)
}

final class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL) {
        self.requestedURL = url
    }
}

final class RemoteProductsLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
    
        let client = HTTPClientSpy()

        _ = RemoteProductsLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    
    func test_load_requestDataFromURL() {
        
        let exampleURL = URL(string: "https://an-example.com/products")!
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(client: client, url: exampleURL)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, exampleURL)
    }
}
