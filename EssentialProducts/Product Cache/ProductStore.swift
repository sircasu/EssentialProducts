//
//  ProductStore.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 25/11/24.
//

import Foundation

public protocol ProductStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func delete(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
