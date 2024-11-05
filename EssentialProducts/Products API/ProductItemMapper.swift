//
//  ProductItemMapper.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 05/11/24.
//

import Foundation

final class ProductItemMapper {
    
     struct RemoteProductItem: Decodable {
        let id: Int
        let title: String
        let price: Double
        let description: String
        let category: String
        let image: URL
        let rating: RemoteProductRatingItem

        var toItems: ProductItem {
            ProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: ProductRatingItem(rate: rating.rate, count: rating.count))
        }
    }

    struct RemoteProductRatingItem: Decodable {
        let rate: Double
        let count: Int
        
        init(rate: Double, count: Int) {
            self.rate = rate
            self.count = count
        }
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ProductItem] {
        
        guard response.statusCode == OK_200 else { throw RemoteProductsLoader.Error.invalidData }
        
        return try JSONDecoder().decode([RemoteProductItem].self, from: data).map { $0.toItems }
    }
}
