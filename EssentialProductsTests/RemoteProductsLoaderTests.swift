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
    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        var clientErrors: [RemoteProductsLoader.Error] = []
        sut.load { clientErrors.append($0) }
        
        client.complete(with: NSError(domain: "test", code: 0))
        
        XCTAssertEqual(clientErrors, [.connectivity])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com/products")!) -> (sut: RemoteProductsLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    final class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] = [URL]()
        var completions: [(Error) -> Void] = []
        
        func get(from url: URL, completion: @escaping (Error?) -> Void) {
            completions.append(completion)
            self.requestedURLs.append(url)
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            completions[index](error)
        }
    }
}
