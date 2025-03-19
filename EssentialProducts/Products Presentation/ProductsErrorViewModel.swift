//
//  ProductsErrorViewModel.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 19/03/25.
//

import Foundation

public struct ProductsErrorViewModel {
    public var message: String?
    
    static var noError: ProductsErrorViewModel {
        return ProductsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ProductsErrorViewModel {
        return ProductsErrorViewModel(message: message)
    }
}
