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
    
        let refreshController = ProductRefreshViewController(productsLoader: productsLoader)
        let productsViewController = ProductsViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak productsViewController] products in
            productsViewController?.collectionModel = products.map { product in
                ProductItemCellViewController(model: product, imageLoader: imageLoader)
            }
        }
        
        return productsViewController
    }
}
