//
//  ProductItem.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

public struct ProductItem: Equatable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: URL
    let rating: ProductRatingItem
}

public struct ProductRatingItem: Equatable {
    let rate: Double
    let count: Int
}
