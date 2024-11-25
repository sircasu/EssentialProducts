//
//  LocalProductLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 25/11/24.
//

import Foundation

public class LocalProductsLoader {
    
    let store: ProductStore
    let currentDate: () -> Date
    
    public init(store: ProductStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [ProductItem], completion: @escaping (Error?) -> Void) {
        store.delete() { [weak self] error in
            
            guard let self = self else { return }
            
            if error != nil {
                completion(error)

            } else {
                self.insert(items, completion: completion)
            }

        }
    }
    
    private func insert(_ items: [ProductItem], completion: @escaping (Error?) -> Void) {
        self.store.insert(items, timestamp: self.currentDate()) { [weak self] error in
            
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
