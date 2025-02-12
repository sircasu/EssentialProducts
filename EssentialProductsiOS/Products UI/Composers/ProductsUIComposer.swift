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
    
        let viewModel = ProductsViewModel(productsLoader: productsLoader)
        let refreshController = ProductRefreshViewController(viewModel: viewModel)
        let productsViewController = ProductsViewController(refreshController: refreshController)
        
        viewModel.onProductsLoad = adaptProductsToCellControllers(forardingTo: productsViewController, loader: imageLoader)
        
        return productsViewController
    }
    
    
    private static func adaptProductsToCellControllers(forardingTo controller: ProductsViewController, loader: ProductImageDataLoader) -> ([ProductItem]) -> Void {
        return { [weak controller] products in
            controller?.collectionModel = products.map { product in
                let viewModel = ProductImageViewModel(model: product, imageLoader: loader, imageTransformer: UIImage.init)
                return ProductItemCellController(viewModel: viewModel)
            }
        }
    }
}
