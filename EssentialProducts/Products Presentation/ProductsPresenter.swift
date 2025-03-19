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

public struct ProductsLoadingViewModel {
    public let isLoading: Bool
}



public protocol ProductsView {
    func display(_ viewModel: ProductsViewModel)
}

public struct ProductsViewModel {
    public let products: [ProductItem]
}



public protocol ProductsErrorView {
    func display(_ viewModel: ProductsErrorViewModel)
}

public struct ProductsErrorViewModel {
    public var message: String?
    
    static var noError: ProductsErrorViewModel {
        return ProductsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ProductsErrorViewModel {
        return ProductsErrorViewModel(message: message)
    }
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
