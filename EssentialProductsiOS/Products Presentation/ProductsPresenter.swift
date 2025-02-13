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
    
    var productsLoadingView: ProductsLoadingView?
    var productsView: ProductsView?
    
    func didStartLoadingProducts() {
        productsLoadingView?.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingProducts(with products: [ProductItem]) {
        productsView?.display(ProductsViewModel(products: products))
        productsLoadingView?.display(ProductsLoadingViewModel(isLoading: false))
    }
    
    
    func didFinishLoadingProductsWithError() {
        productsLoadingView?.display(ProductsLoadingViewModel(isLoading: false))
    }
}

