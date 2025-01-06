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
    
    public init (bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "ProductStore", in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedProducts(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [EssentialProducts.LocalProductItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadePersistentStore(Swift.Error)
    }
    
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Swift.Error?
        container.loadPersistentStores { description, error in
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


private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var products: NSOrderedSet
}

private class ManagedProduct: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var price: Double
    @NSManaged var desc: String
    @NSManaged var category: String
    @NSManaged var imageURL: URL
    @NSManaged var ratingValue: Double
    @NSManaged var ratingCount: Int
    @NSManaged var cache: ManagedCache
}
