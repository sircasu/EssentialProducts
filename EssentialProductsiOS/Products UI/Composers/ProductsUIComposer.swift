//
//  ProductsUIComposer.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import Foundation
import EssentialProducts
import UIKit

public final class ProductsUIComposer {
    private init() {}
    
    public static func productsComposedWith(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) -> ProductsViewController {
    

        let presentationAdapter = ProductsLoaderPresentationAdapter(productsLoader: productsLoader)
        let refreshController = ProductRefreshViewController(delegate: presentationAdapter)
        let productsViewController = ProductsViewController(refreshController: refreshController)
        
        let presenter = ProductsPresenter(
            productsLoadingView: WeakReferenceVirtualProxy(refreshController),
            productsView: ProductsViewAdapter(controller: productsViewController, imageLoader: imageLoader))
        presentationAdapter.presenter = presenter

        return productsViewController
    }
}

private final class ProductsViewAdapter: ProductsView {
    
    private weak var controller: ProductsViewController?
    var imageLoader: ProductImageDataLoader
    
    init(controller: ProductsViewController, imageLoader: ProductImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: ProductsViewModel) {
        controller?.collectionModel = viewModel.products.map { product in

            let presenter = ProductImagePresenter(model: product, imageLoader: imageLoader)
            let cell = ProductItemCellController(presenter: presenter)
            presenter.view = WeakReferenceVirtualProxy(cell)
            return cell
        }
    }
}


private final class WeakReferenceVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakReferenceVirtualProxy: ProductsLoadingView where T: ProductsLoadingView {

    func display(_ viewModel: ProductsLoadingViewModel) {
        object?.display(viewModel)
    }
    
}
extension WeakReferenceVirtualProxy: ProductImageView where T: ProductImageView {

    func display(viewModel: ProductImagePresenterViewModel) {
        object?.display(viewModel: viewModel)
    }
}


final class ProductsLoaderPresentationAdapter: ProductRefreshViewControllerDelegate {
    
    
    private let productsLoader: ProductsLoader
    var presenter: ProductsPresenter?
    
    init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    func didRequestProductsRefresh() {
        
        presenter?.didStartLoadingProducts()
        
        productsLoader.load { [weak self] result in
            switch result {
            case let .success(products):
                self?.presenter?.didFinishLoadingProducts(with: products)
            case .failure:
                self?.presenter?.didFinishLoadingProductsWithError()
            }
        }
        
    }
}
