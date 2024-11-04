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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [exampleURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice()  {
        
        let exampleURL = URL(string: "https://an-example.com/products")!
        let (sut, client) = makeSUT(url: exampleURL)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [exampleURL, exampleURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, with: [.failure(.connectivity)], when: {
            client.complete(with: NSError(domain: "test", code: 0))
        })
    }
    
    func test_load_deliversErrorOnInvalidData() {
        
        let (sut, client) = makeSUT()
        
        let errorCodeSample = [199, 201, 300, 400, 500]
        errorCodeSample.enumerated().forEach { index, code in
            expect(sut, with: [.failure(.invalidData)], when: {
                client.complete(with: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, with: [.failure(.invalidData)], when: {
            let invalidJsonData = Data("invalid json".utf8)
            client.complete(with: 200, data: invalidJsonData)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, with: [.success([])], when: {
            let emptyJSON = Data("[]".utf8)
            client.complete(with: 200, data: emptyJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONListItems() {
        let (sut, client) = makeSUT()
        
        var clientResults: [RemoteProductsLoader.Result] = []
        sut.load { clientResults.append($0) }
        
        let product1 = ProductItem(id: 1, title: "a title", price: 20, description: "a description", category: "a category", image: URL(string: "https://example.com/products/1.jpg")!, rating: ProductRatingItem(rate: 3, count: 5))
        let product1JSON = [
            "id": 1,
            "title": "a title",
            "price": 20,
            "description": "a description",
            "category": "a category",
            "image": "https://example.com/products/1.jpg",
            "rating": ["rate": 3, "count": 5]
        ] as [String : Any]
        
        let product2 = ProductItem(id: 2, title: "another title", price: 15, description: "another description", category: "another category", image: URL(string: "https://example.com/products/2.jpg")!, rating: ProductRatingItem(rate: 4, count: 12))
        let product2JSON = [
            "id": 2,
            "title": "another title",
            "price": 15,
            "description": "another description",
            "category": "another category",
            "image": "https://example.com/products/2.jpg",
            "rating": ["rate": 4, "count": 12]
        ] as [String : Any]
        
        let json = try! JSONSerialization.data(withJSONObject: [product1JSON, product2JSON])
        client.complete(with: 200, data: json)
        
        XCTAssertEqual(clientResults, [.success([product1, product2])])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com/products")!) -> (sut: RemoteProductsLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteProductsLoader, with results: [RemoteProductsLoader.Result], when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var clientResults: [RemoteProductsLoader.Result] = []
        sut.load { clientResults.append($0) }
        
        action()
        
        XCTAssertEqual(clientResults, results, file: file, line: line)
    }
    
    final class HTTPClientSpy: HTTPClient {
        
        private var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
    }
}
