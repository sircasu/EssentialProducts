//
//  CodableProductStore.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 05/01/25.
//

import Foundation

public final class CodableProductStore: ProductStore {
    
    private let queue = DispatchQueue(label: "\(CodableProductStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct CodableProductItem: Codable {
        private let id: Int
        private let title: String
        private let price: Double
        private let description: String
        private let category: String
        private let image: URL
        private let rating: CodableProductRatingItem
        
        init(_ item: LocalProductItem) {
            id = item.id
            title = item.title
            price = item.price
            description = item.description
            category = item.category
            image = item.image
            rating = CodableProductRatingItem(item.rating)
        }
        
        var local: LocalProductItem { LocalProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: rating.local) }
    }

    private struct CodableProductRatingItem: Codable {
        private let rate: Double
        private let count: Int
        
        init(_ item: LocalProductRatingItem) {
            rate = item.rate
            count = item.count
        }
        
        var local: LocalProductRatingItem { LocalProductRatingItem(rate: rate, count: count) }
    }
    
    private struct Cache: Codable {
        let products: [CodableProductItem]
        let timestamp: Date
        
        var localProducts: [LocalProductItem] {
            products.map { $0.local }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(cache.localProducts, cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(products: items.map (CodableProductItem.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedProducts(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
}
