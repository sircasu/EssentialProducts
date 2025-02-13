//
//  CoreDataProductStore.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 06/01/25.
//

import Foundation
import CoreData

public class CoreDataProductStore: ProductStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init (storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "ProductDataStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedProducts(completion: @escaping DeletionCompletion) {

        perform { context in
            
            completion( Result {
                try ManagedCache.find(in: context).map(context.delete)
            })
//            do {
//                try ManagedCache.find(in: context).map(context.delete)
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
        }
    }
    
    public func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        perform { context in
            completion( Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.products = ManagedProduct.products(from: items, in: context)

                try context.save()
            })
//            do {
//                let managedCache = try ManagedCache.newUniqueInstance(in: context)
//                managedCache.timestamp = timestamp
//                managedCache.products = ManagedProduct.products(from: items, in: context)
//
//                try context.save()
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {

        perform { context in
            completion( Result {
                try ManagedCache.find(in: context).map {
                    return CachedProducts(products: $0.localProducts, timestamp: $0.timestamp)
                }
            })
//            do {
//                if let cache = try ManagedCache.find(in: context) {
//                    completion(.success(CachedProducts(products: cache.localProducts, timestamp: cache.timestamp)))
//                } else {
//                    completion(.success(.none))
//                }
//            } catch {
//                completion(.failure(error))
//            }
        }
    }
    
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
}
