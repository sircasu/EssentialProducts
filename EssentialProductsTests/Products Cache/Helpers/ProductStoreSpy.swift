//
//  ProductStoreSpy.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 29/11/24.
//

import Foundation
import EssentialProducts

public class ProductStoreSpy: ProductStore {
            
    enum ReceivedMessages: Equatable {
        case deleteCachedProducts
        case insert([LocalProductItem], Date)
    }
    
    var insertions = [(items: [LocalProductItem], timestamp: Date)]()
    var receivedMessages: [ReceivedMessages] = [ReceivedMessages]()
    
    var deletionCompletions: [DeletionCompletion] = [DeletionCompletion]()
    var insertionsCompletion: [InsertionCompletion] = [InsertionCompletion]()
    
    public func delete(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedProducts)
    }
    
    func completeWithError(error: Error?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    public func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertions.append((items, timestamp))
        receivedMessages.append(.insert(items, timestamp))
        insertionsCompletion.append(completion)
    }
    
    func completeInsertWithError(error: Error?, at index: Int = 0) {
        insertionsCompletion[index](error)
    }
    
    func completeInsertSuccessfully(at index: Int = 0) {
        insertionsCompletion[index](nil)
    }
}
