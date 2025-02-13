//
//  ProductRefreshViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit

public protocol ProductRefreshViewControllerDelegate {
    func didRequestProductsRefresh()
}

public final class ProductRefreshViewController: NSObject, ProductsLoadingView {
    
    public lazy var view: UIRefreshControl = loadView()

    private let delegate: ProductRefreshViewControllerDelegate
    
    public init(delegate: ProductRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func display(_ viewModel: ProductsLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    @objc func refresh() {
        delegate.didRequestProductsRefresh()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
