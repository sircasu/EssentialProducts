//
//  ProductCachePolicy.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 11/12/24.
//

import Foundation

final class ProductCachePolicy {
    
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)

    private static var maxCacheAge: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCaheAge = calendar.date(byAdding: .day, value: maxCacheAge, to: timestamp) else {
            return false
        }
        return date < maxCaheAge
    }
}
