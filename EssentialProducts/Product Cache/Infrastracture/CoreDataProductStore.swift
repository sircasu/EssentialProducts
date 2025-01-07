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
            do {
                try ManagedCache.find(in: context).map(context.delete)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ items: [LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.products = ManagedProduct.products(from: items, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {

        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(cache.localProducts, cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
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
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    var localProducts: [LocalProductItem] {
        return products.compactMap { ($0 as? ManagedProduct)?.local }
    }
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
    
    static func products(from items: [LocalProductItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        
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
        
        return NSOrderedSet(array: managedProducts)
    }
    
    var local: LocalProductItem {
        return LocalProductItem(id: id, title: title, price: price, description: desc, category: category, image: imageURL, rating: LocalProductRatingItem(rate: ratingValue, count: ratingCount))
    }
}
