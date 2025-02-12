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
        return bind(UIRefreshControl())
    }()
    
    private let viewModel: ProductsViewModel
    
    public init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadProduct()
    }
    
    func bind(_ view: UIRefreshControl) -> UIRefreshControl {
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
