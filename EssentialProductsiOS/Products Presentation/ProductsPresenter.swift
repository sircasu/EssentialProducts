//
//  ProductsPresenter.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 13/02/25.
//

import Foundation
import EssentialProducts

protocol ProductsLoadingView {
    func display(isLoading: Bool)
}

protocol ProductsView {
    func display(products: [ProductItem])
}

public final class ProductsPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let productsLoader: ProductsLoader?

    public init(productsLoader: ProductsLoader?) {
        self.productsLoader = productsLoader
    }
    
    var productsLoadingView: ProductsLoadingView?
    var productsView: ProductsView?
    
    func loadProduct() {
        productsLoadingView?.display(isLoading: true)
        
        productsLoader?.load { [weak self] result in
    
            if let products = try? result.get() {
                self?.productsView?.display(products: products)
            }
            self?.productsLoadingView?.display(isLoading: false)
        }
    }
}

