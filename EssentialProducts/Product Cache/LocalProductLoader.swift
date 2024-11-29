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
    
    public typealias SaveResult = Error?
    public typealias LoadResult = ProductsLoader.Result
    
    public init(store: ProductStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [ProductItem], completion: @escaping (SaveResult) -> Void) {
        store.delete() { [weak self] error in
            
            guard let self = self else { return }
            
            if error != nil {
                completion(error)

            } else {
                self.cache(items, completion: completion)
            }

        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { error in
            if let error {
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ items: [ProductItem], completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            
            guard self != nil else { return }
            
            completion(error)
        }
    }
}


extension Array where Element == ProductItem {
    func toLocal() -> [LocalProductItem] {
        map { LocalProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.description, category: $0.category, image: $0.image, rating: LocalProductRatingItem(rate: $0.rating.rate, count: $0.rating.count)) }
    }
}
