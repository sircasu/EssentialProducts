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
        
    }
    
    public func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                
                let managedProducts: [ManagedProduct] = items.map { local in
                    let managedProduct = ManagedProduct(context: context)
                    managedProduct.id = local.id
                    managedProduct.title = local.title
                    managedProduct.price = local.price
                    managedProduct.desc = local.description
                    managedProduct.category = local.category
                    managedProduct.imageURL = local.image
                    managedProduct.ratingCount = local.rating.count
                    managedProduct.ratingValue = local.rating.rate
                    return managedProduct
                }
                managedCache.products = NSOrderedSet(array: managedProducts)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {

        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(
                        cache.products
                            .compactMap { $0 as? ManagedProduct }
                            .map {
                                LocalProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.desc, category: $0.category, image: $0.imageURL, rating: LocalProductRatingItem(rate: $0.ratingValue, count: $0.ratingCount))
                            },
                        cache.timestamp
                    ))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadePersistentStore(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        var loadError: Swift.Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        guard loadError == nil else {
            throw LoadingError.failedToLoadePersistentStore(loadError!)
        }
        
        return container
        
    }
    
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var products: NSOrderedSet
}

@objc(ManagedProduct)
private class ManagedProduct: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var price: Double
    @NSManaged var desc: String
    @NSManaged var category: String
    @NSManaged var imageURL: URL
    @NSManaged var ratingValue: Double
    @NSManaged var ratingCount: Int
    @NSManaged var cache: ManagedCache
}
