//
//  ProductItemMapper.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 05/11/24.
//

import Foundation

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
