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
    
        let presenter = ProductsPresenter(productsLoader: productsLoader)
        let refreshController = ProductRefreshViewController(presenter: presenter)
        let productsViewController = ProductsViewController(refreshController: refreshController)
        
        presenter.productsLoadingView = WeakReferenceVirtualProxy(refreshController)
        presenter.productsView = ProductsViewAdapter(controller: productsViewController, imageLoader: imageLoader)

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
            let viewModel = ProductImageViewModel(model: product, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return ProductItemCellController(viewModel: viewModel)
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
