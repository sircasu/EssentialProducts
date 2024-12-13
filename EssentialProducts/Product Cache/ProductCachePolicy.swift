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

    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
