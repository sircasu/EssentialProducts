//
//  ProductsViewModel.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 12/02/25.
//

import EssentialProducts

public final class ProductsViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let productsLoader: ProductsLoader?

    public init(productsLoader: ProductsLoader?) {
        self.productsLoader = productsLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onProductsLoad: Observer<[ProductItem]>?
    
    func loadProduct() {
        onLoadingStateChange?(true)
        
        productsLoader?.load { [weak self] result in
    
            if let products = try? result.get() {
                self?.onProductsLoad?(products)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
