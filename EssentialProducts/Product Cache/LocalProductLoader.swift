//
//  LocalProductLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 25/11/24.
//

import Foundation

final class ProductCachePolicy {
    
    private let calendar = Calendar(identifier: .gregorian)
    let currentDate: () -> Date

    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAge: Int { 7 }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCaheAge = calendar.date(byAdding: .day, value: maxCacheAge, to: timestamp) else {
            return false
        }
        return currentDate() < maxCaheAge
    }
}

public class LocalProductsLoader: ProductsLoader {
    
    let store: ProductStore
    let currentDate: () -> Date
    private let productCachePolicy: ProductCachePolicy
    
    public init(store: ProductStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.productCachePolicy = ProductCachePolicy(currentDate: currentDate)
    }
}

extension LocalProductsLoader {
    
    public typealias SaveResult = Error?
    
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
            case let .found(products, timestamp) where self.productCachePolicy.validate(timestamp):
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
                store.delete { _ in }
            case let .found(_, timestamp) where !self.productCachePolicy.validate(timestamp):
                store.delete { _ in }
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
