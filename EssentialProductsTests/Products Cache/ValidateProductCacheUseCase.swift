//
//  ValidatwProductCacheUseCase.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 09/12/24.
//

import XCTest
import EssentialProducts

final class ValidateProductCacheUseCase: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithError(error: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedProducts])
    }
    
    func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyItems()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOn7DaysOldCache() {
        
        let fixedCurrentDate = Date()
        let sevenDayOldTimestamp = fixedCurrentDate.adding(days: -7)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: products.local, timestamp: sevenDayOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedProducts])
    }
    
    func test_validateCache_doesNotDeleteOnLessThan7DaysOldCache() {
        let fixedCurrentDate = Date.init()
        let products = uniqueItems()
        let lessThanSevenDayOldTimestamp = Date.init().adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT() { fixedCurrentDate }

        sut.validateCache()
        
        store.completeRetrieval(with: products.local, timestamp: lessThanSevenDayOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnMoreThan7DaysOldCache() {
        
        let fixedCurrentDate = Date()
        let moreThanSevenDayOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: -1)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.validateCache()
        store.completeRetrieval(with: products.local, timestamp: moreThanSevenDayOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedProducts])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStoreSpy) {
        let store = ProductStoreSpy()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private func uniqueItem(id: Int) -> ProductItem {
        return ProductItem(id: 1, title: "any title", price: 12.99, description: "a description", category: "a category", image: anyURL(), rating: ProductRatingItem(rate: 4.3, count: 24))
    }
    
    private func uniqueItems() -> (model: [ProductItem], local: [LocalProductItem]) {
        let items = [uniqueItem(id: 1), uniqueItem(id: 2)]
        
        let localItems = items.map { LocalProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.description, category: $0.category, image: $0.image, rating: LocalProductRatingItem(rate: $0.rating.rate, count: $0.rating.count))}
        
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://example.com/")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return Date.init() + seconds
    }
}
