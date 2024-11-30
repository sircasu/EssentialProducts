//
//  ProductStore.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 25/11/24.
//

import Foundation

public enum RetrievalCachedProductResult {
    case failure(Error)
    case empty
    case found([LocalProductItem], Date)
}

public protocol ProductStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalCachedProductResult) -> Void
    
    func delete(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
