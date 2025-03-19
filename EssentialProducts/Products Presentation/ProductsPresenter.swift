//
//  ProductsPresenter.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 19/03/25.
//

import Foundation

public protocol ProductsLoadingView {
    func display(_ viewModel: ProductsLoadingViewModel)
}

public protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

public protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}

public final class ProductsPresenter {
    var productsLoadingView: ProductsLoadingView
    var productsView: ProductsView
    var productsErrorView: ProductsErrorView
    
    public init(productsLoadingView: ProductsLoadingView, productsView: ProductsView, productsErrorView: ProductsErrorView) {
        self.productsLoadingView = productsLoadingView
        self.productsView = productsView
        self.productsErrorView = productsErrorView
    }
    
    public static var title: String {
        NSLocalizedString("PRODUCTS_VIEW_TITLE", tableName: "Products", bundle: Bundle(for: ProductsPresenter.self), comment: "Title for products view")
    }
    
    public static var loadError: String {
        NSLocalizedString("PRODUCTS_VIEW_CONNECTION_ERROR", tableName: "Products", bundle: Bundle(for: ProductsPresenter.self), comment: "Error message displayed when we can't load products from server")
    }
    
    public func didStartLoadingProducts() {
        productsErrorView.display(.noError)
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingProducts(with products: [ProductItem]) {
        productsView.display(ProductsViewModel(products: products))
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingProductsWithError() {
        productsErrorView.display(.error(message: ProductsPresenter.loadError))
        productsLoadingView.display(ProductsLoadingViewModel(isLoading: false))
    }
}
