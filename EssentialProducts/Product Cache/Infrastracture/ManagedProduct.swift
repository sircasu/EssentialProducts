//
//  ManagedProduct.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 07/01/25.
//

import CoreData

@objc(ManagedProduct)
class ManagedProduct: NSManagedObject {
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

extension ManagedProduct {
    
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
