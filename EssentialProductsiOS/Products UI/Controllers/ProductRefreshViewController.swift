//
//  ProductRefreshViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit
import EssentialProducts

public final class ProductRefreshViewController: NSObject {
    
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let productsLoader: ProductsLoader?
    
    public init(productsLoader: ProductsLoader?) {
        self.productsLoader = productsLoader
    }
    
    var onRefresh: (([ProductItem]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        productsLoader?.load { [weak self] result in
    
            if let products = try? result.get() {
                self?.onRefresh?(products)
            }
            self?.view.endRefreshing()
        }
    }
}
