//
//  LocalProductLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 25/11/24.
//

import Foundation

public class LocalProductsLoader: ProductsLoader {
    
    private let store: ProductStore
    private let currentDate: () -> Date
    
    public init(store: ProductStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalProductsLoader {
    
    public typealias SaveResult = Error?
    
    public func save(_ items: [ProductItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedProducts() { [weak self] error in
            
            guard let self = self else { return }
            
            if error != nil {
                completion(error)
                
            } else {
                self.cache(items, completion: completion)
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

extension LocalProductsLoader {
    
    public typealias LoadResult = ProductsLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(products, timestamp) where ProductCachePolicy.validate(timestamp, against: currentDate()):
                completion(.success(products.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalProductsLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .failure:
                store.deleteCachedProducts { _ in }
            case let .found(_, timestamp) where !ProductCachePolicy.validate(timestamp, against: currentDate()):
                store.deleteCachedProducts { _ in }
            case .found, .empty:
                break
                
            }
        }
    }
}


extension Array where Element == ProductItem {
    func toLocal() -> [LocalProductItem] {
        map { LocalProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.description, category: $0.category, image: $0.image, rating: LocalProductRatingItem(rate: $0.rating.rate, count: $0.rating.count)) }
    }
}

extension Array where Element == LocalProductItem {
    func toModels() -> [ProductItem] {
        map { ProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.description, category: $0.category, image: $0.image, rating: ProductRatingItem(rate: $0.rating.rate, count: $0.rating.count)) }
    }
}
