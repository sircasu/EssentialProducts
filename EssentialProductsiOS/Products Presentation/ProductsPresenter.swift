//
//  ProductsPresenter.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 13/02/25.
//

import Foundation
import EssentialProducts


protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}

public final class ProductsPresenter {
    typealias Observer<T> = (T) -> Void
    
    var productsLoadingView: ProductsLoadingView
    var productsView: ProductsView
    var productsErrorView: ProductsErrorView
    
    init(productsLoadingView: ProductsLoadingView, productsView: ProductsView, productsErrorView: ProductsErrorView) {
        self.productsLoadingView = productsLoadingView
        self.productsView = productsView
        self.productsErrorView = productsErrorView
    }
    
    static var title: String {
        NSLocalizedString("PRODUCTS_VIEW_TITLE", tableName: "Products", bundle: Bundle(for: ProductsPresenter.self), comment: "Title for products view")
    }
    
    static var loadError: String {
        NSLocalizedString("PRODUCTS_VIEW_CONNECTION_ERROR", tableName: "Products", bundle: Bundle(for: ProductsPresenter.self), comment: "Error message displayed when we can't load products from server")
    }
    
    func didStartLoadingProducts() {
        productsErrorView.display(.noError)
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingProducts(with products: [ProductItem]) {
        productsView.display(ProductsViewModel(products: products))
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: false))
    }
    
    
    func didFinishLoadingProductsWithError() {
        productsErrorView.display(.error(message: ProductsPresenter.loadError))
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: false))
    }
}

