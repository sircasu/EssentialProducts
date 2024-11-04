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
                client.complete(with: code, data: makeEmptyJSON(), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, with: [.failure(.invalidData)], when: {
            let invalidJsonData = makeInvalidJSON()
            client.complete(with: 200, data: invalidJsonData)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, with: [.success([])], when: {
            let emptyJSON = makeEmptyJSON()
            client.complete(with: 200, data: emptyJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONListItems() {
        let (sut, client) = makeSUT()
        
        var clientResults: [RemoteProductsLoader.Result] = []
        sut.load { clientResults.append($0) }
        
        let product1 = makeItem(id: 1, title: "a title", price: 20, description: "a description", category: "a category", image: URL(string: "https://example.com/products/1.jpg")!, rating: ProductRatingItem(rate: 3, count: 5))
   
        let product2 = makeItem(id: 2, title: "another title", price: 15, description: "another description", category: "another category", image: URL(string: "https://example.com/products/2.jpg")!, rating: ProductRatingItem(rate: 4, count: 12))
 
        let json = makeItemsJSON([product1.json, product2.json])
        client.complete(with: 200, data: json)
        
        XCTAssertEqual(clientResults, [.success([product1.model, product2.model])])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com/products")!) -> (sut: RemoteProductsLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteProductsLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    private func makeItem(id: Int, title: String, price: Double, description: String, category: String, image: URL, rating: ProductRatingItem) -> (model: ProductItem, json: [String: Any]) {
        
        let model = ProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: rating)
        let json = [
            "id": model.id,
            "title": model.title,
            "price": model.price,
            "description": model.description,
            "category": model.category,
            "image": model.image.absoluteString,
            "rating": ["rate": rating.rate, "count": rating.count]
        ] as [String : Any]
        
        return (model, json)
    }
    
    func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = items
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func makeInvalidJSON() -> Data {
        Data("invalid json".utf8)
    }
    
    func makeEmptyJSON() -> Data {
        Data("[]".utf8)
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
        
        func complete(with code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
    }
}
