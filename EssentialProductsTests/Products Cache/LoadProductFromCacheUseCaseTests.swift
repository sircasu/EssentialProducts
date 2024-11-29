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
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalProductsLoader, ProductStoreSpy) {
        let store = ProductStoreSpy()
        let sut = LocalProductsLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    private class ProductStoreSpy: ProductStore {
                
        enum ReceivedMessages: Equatable {
            case deleteCachedProducts
            case insert([LocalProductItem], Date)
        }
        
        var insertions = [(items: [LocalProductItem], timestamp: Date)]()
        var receivedMessages: [ReceivedMessages] = [ReceivedMessages]()
        
        var deletionCompletions: [DeletionCompletion] = [DeletionCompletion]()
        var insertionsCompletion: [InsertionCompletion] = [InsertionCompletion]()
        
        func delete(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedProducts)
        }
        
        func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertions.append((items, timestamp))
            receivedMessages.append(.insert(items, timestamp))
            insertionsCompletion.append(completion)
        }
        
        func completeWithError(error: Error?, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertWithError(error: Error?, at index: Int = 0) {
            insertionsCompletion[index](error)
        }
        func completeInsertSuccessfully(at index: Int = 0) {
            insertionsCompletion[index](nil)
        }
    }
}
