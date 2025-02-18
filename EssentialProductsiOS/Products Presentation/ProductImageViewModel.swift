//
//  ProductImageViewModel.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 18/02/25.
//

import Foundation

struct ProductImageViewModel<Image> {
    var name: String
    var description: String
    var price: String
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
}
