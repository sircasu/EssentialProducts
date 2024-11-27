//
//  ProductItemMapper.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 05/11/24.
//

import Foundation

struct RemoteProductItem: Decodable {
   let id: Int
   let title: String
   let price: Double
   let description: String
   let category: String
   let image: URL
   let rating: RemoteProductRatingItem
    
    struct RemoteProductRatingItem: Decodable {
        let rate: Double
        let count: Int
        
        init(rate: Double, count: Int) {
            self.rate = rate
            self.count = count
        }
    }
}

final class ProductItemMapper {
   
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteProductItem] {
        
        guard response.statusCode == OK_200,
              let items = try? JSONDecoder().decode([RemoteProductItem].self, from: data) else {
            throw RemoteProductsLoader.Error.invalidData
        }

        return items
    }
}
