//
//  CoreDataProductStore.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 06/01/25.
//

import Foundation

public class CoreDataProductStore: ProductStore {
    
    public init() {}
    
    public func deleteCachedProducts(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [EssentialProducts.LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}
