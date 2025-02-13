//
//  ProductRefreshViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit

public final class ProductRefreshViewController: NSObject, ProductsLoadingView {
    
    public lazy var view: UIRefreshControl = loadView()
    
    private let presenter: ProductsPresenter
    
    public init(presenter: ProductsPresenter) {
        self.presenter = presenter
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    @objc func refresh() {
        presenter.loadProduct()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
