//
//  RemoteProductItem.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 27/11/24.
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
