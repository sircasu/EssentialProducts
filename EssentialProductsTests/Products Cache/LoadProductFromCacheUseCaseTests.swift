//
//  LoadProductFromCacheUseCaseTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 29/11/24.
//

import XCTest
import EssentialProducts

final class LoadProductFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {

        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_askForProductRetrieval() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(expectedError), when: {
            store.completeRetrievalWithError(error: expectedError)
        })
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyItems()
        })
    }
    
    func test_load_deliversCachedProductOnLessThan7DaysOldCache() {
        
        let fixedCurrentDate = Date.init()
        let products = uniqueItems()
        let lessThanSevenDayOldTimestamp = Date.init().adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT() { fixedCurrentDate }

        expect(sut, toCompleteWith: .success(products.model), when: {
            store.completeRetrieval(with: products.local, timestamp: lessThanSevenDayOldTimestamp)
        })
    }
    
    func test_load_doesNotDeliverProductsOn7DaysOldCache() {
        
        let fixedCurrentDate = Date()
        let sevenDayOldTimestamp = fixedCurrentDate.adding(days: -7)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: products.local, timestamp: sevenDayOldTimestamp)
        })
    }
        
    func test_load_doesNotDeliverProductsOnMoreThan7DaysOldCache() {
        
        let fixedCurrentDate = Date()
        let moreThanSevenDayOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: -1)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: products.local, timestamp: moreThanSevenDayOldTimestamp)
        })
    }
    
    func test_load_hasNosideEffectsOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithError(error: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
        
    func test_load_hasNoSideEffectOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyItems()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOn7DaysOldCache() {
        
        let fixedCurrentDate = Date()
        let sevenDayOldTimestamp = fixedCurrentDate.adding(days: -7)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: products.local, timestamp: sevenDayOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteOnLessThan7DaysOldCache() {
        let fixedCurrentDate = Date.init()
        let products = uniqueItems()
        let lessThanSevenDayOldTimestamp = Date.init().adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT() { fixedCurrentDate }

        sut.load { _ in }
        
        store.completeRetrieval(with: products.local, timestamp: lessThanSevenDayOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
        
    func test_load_hasNoSideEffectOnMoreThan7DaysOldCache() {
        
        let fixedCurrentDate = Date()
        let moreThanSevenDayOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: -1)
        let products = uniqueItems()
        let (sut, store) = makeSUT() { fixedCurrentDate }
        
        sut.load { _ in }
        store.completeRetrieval(with: products.local, timestamp: moreThanSevenDayOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliversResultAfterSUTHasBeenDeallocated() {
        
        let store = ProductStoreSpy()
        var sut: LocalProductsLoader? = LocalProductsLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalProductsLoader.LoadResult]()
        sut?.load { receivedResult.append($0) }
        
        sut = nil
        
        store.completeRetrievalWithEmptyItems()
        
        XCTAssertTrue(receivedResult.isEmpty)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStoreSpy) {
        let store = ProductStoreSpy()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private func expect(_ sut: LocalProductsLoader, toCompleteWith expectedResult: LocalProductsLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedItems), .success(let expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default: XCTFail("Expected \(expectedResult) but received \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
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
