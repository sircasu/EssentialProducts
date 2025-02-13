//
//  ProductsPresenter.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 13/02/25.
//

import Foundation
import EssentialProducts

struct ProductsLoadingViewModel {
    let isLoading: Bool
}
protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

struct ProductsViewModel {
    let products: [ProductItem]
}
protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

public final class ProductsPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let productsLoader: ProductsLoader?

    public init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    var productsLoadingView: ProductsLoadingView?
    var productsView: ProductsView?
    
    func loadProducts() {
        productsLoadingView?.display(ProductsLoadingViewModel(isLoading: true))
        
        productsLoader?.load { [weak self] result in
    
            if let products = try? result.get() {
                self?.productsView?.display(ProductsViewModel(products: products))
            }
            self?.productsLoadingView?.display(ProductsLoadingViewModel(isLoading: false))
        }
    }
}

