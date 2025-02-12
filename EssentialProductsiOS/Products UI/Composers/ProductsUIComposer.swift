//
//  ProductsUIComposer.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import Foundation
import EssentialProducts

public final class ProductsUIComposer {
    private init() {}
    
    public static func productsComposedWith(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) -> ProductsViewController {
    
        let viewModel = ProductsViewModel(productsLoader: productsLoader)
        let refreshController = ProductRefreshViewController(viewModel: viewModel)
        let productsViewController = ProductsViewController(refreshController: refreshController)
        
        viewModel.onProductsLoad = adaptProductsToCellControllers(forardingTo: productsViewController, loader: imageLoader)
        
        return productsViewController
    }
    
    
    private static func adaptProductsToCellControllers(forardingTo controller: ProductsViewController, loader: ProductImageDataLoader) -> ([ProductItem]) -> Void {
        return { [weak controller] products in
            controller?.collectionModel = products.map { product in
                ProductItemCellController(model: product, imageLoader: loader)
            }
        }
    }
}
