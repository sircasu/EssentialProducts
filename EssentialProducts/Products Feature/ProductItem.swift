//
//  ProductItem.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

public struct ProductItem: Equatable, Decodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: URL
    let rating: ProductRatingItem
    
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

public struct ProductRatingItem: Equatable, Decodable {
    let rate: Double
    let count: Int
    
    public init(rate: Double, count: Int) {
        self.rate = rate
        self.count = count
    }
}
