//
//  ProductItem.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

public struct ProductItem: Equatable {
    public let id: Int
    public let title: String
    public let price: Double
    public  let description: String
    public let category: String
    public let image: URL
    public  let rating: ProductRatingItem
    
    public init(id: Int, title: String, price: Double, description: String, category: String, image: URL, rating: ProductRatingItem) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.image = image
        self.rating = rating
    }
}

public struct ProductRatingItem: Equatable {
    public let rate: Double
    public let count: Int
    
    public init(rate: Double, count: Int) {
        self.rate = rate
        self.count = count
    }
}
