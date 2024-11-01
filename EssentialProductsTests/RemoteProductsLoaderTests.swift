//
//  RemoteProductsLoaderTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 01/11/24.
//

import XCTest
import EssentialProducts

final class RemoteProductsLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
    
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        
        let exampleURL = URL(string: "https://an-example.com/products")!
        let (sut, client) = makeSUT(url: exampleURL)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [exampleURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice()  {
        
        let exampleURL = URL(string: "https://an-example.com/products")!
        let (sut, client) = makeSUT(url: exampleURL)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [exampleURL, exampleURL])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com/products")!) -> (sut: RemoteProductsLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    final class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] = [URL]()
        
        func get(from url: URL) {
            self.requestedURLs.append(url)
        }
    }
}
