//
//  CodableProductStoreTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 16/12/24.
//

import XCTest
import EssentialProducts

public final class CodableProductStore {
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct CodableProductItem: Codable {
        private let id: Int
        private let title: String
        private let price: Double
        private let description: String
        private let category: String
        private let image: URL
        private let rating: CodableProductRatingItem
        
        init(_ item: LocalProductItem) {
            id = item.id
            title = item.title
            price = item.price
            description = item.description
            category = item.category
            image = item.image
            rating = CodableProductRatingItem(item.rating)
        }
        
        var local: LocalProductItem { LocalProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: rating.local) }
    }

    private struct CodableProductRatingItem: Codable {
        private let rate: Double
        private let count: Int
        
        init(_ item: LocalProductRatingItem) {
            rate = item.rate
            count = item.count
        }
        
        var local: LocalProductRatingItem { LocalProductRatingItem(rate: rate, count: count) }
    }
    
    private struct Cache: Codable {
        let products: [CodableProductItem]
        let timestamp: Date
        
        var localProducts: [LocalProductItem] {
            products.map { $0.local }
        }
    }
    
    func retrieve(completion: @escaping ProductStore.RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(cache.localProducts, cache.timestamp))
    }
    
    func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping ProductStore.InsertionCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(products: items.map (CodableProductItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
    
}

final class CodableProductStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .found(products, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(products, timestamp))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableProductStore {
        let storeURL = testSpecificStoreURL()
        let sut = CodableProductStore(storeURL: storeURL)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ cache: (products: [LocalProductItem], timestamp: Date), to sut: CodableProductStore) {
        
        let exp = expectation(description: "Wait for completion")
        
        sut.insert(cache.products, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected products to be inserted successfully")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableProductStore, toRetrieve expectedResult: RetrievalCachedProductResult, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for completion")
        
        sut.retrieve { retrievedResult in
            
            switch(expectedResult, retrievedResult) {
            case (.empty, .empty):
                break
            case let (.found(expected, expectedTimestamp), .found(retrieved, retrievedTimestamp)):
                XCTAssertEqual(expected, retrieved, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
        
            default: XCTFail("Expected to retrieve \(expectedResult) got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableProductStore, toRetrieveTwice expectedResult: RetrievalCachedProductResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
