//
//  ProductCacheTestHelper.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 09/12/24.
//

import Foundation
import EssentialProducts

func uniqueItem(id: Int) -> ProductItem {
    return ProductItem(id: 1, title: "any title", price: 12.99, description: "a description", category: "a category", image: anyURL(), rating: ProductRatingItem(rate: 4.3, count: 24))
}

func uniqueItems() -> (model: [ProductItem], local: [LocalProductItem]) {
    let items = [uniqueItem(id: 1), uniqueItem(id: 2)]
    
    let localItems = items.map { LocalProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.description, category: $0.category, image: $0.image, rating: LocalProductRatingItem(rate: $0.rating.rate, count: $0.rating.count))}
    
    return (items, localItems)
}

extension Date {
    
    private var productMaxCacheInDays: Int { 7 }
    
    func minusMaxCacheAge() -> Date {
        return adding(days: -productMaxCacheInDays)
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
