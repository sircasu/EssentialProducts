//
//  ProductsViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 05/02/25.
//

import UIKit
import EssentialProducts

final public class ProductsViewController: UICollectionViewController {
    
    private var loader: ProductsLoader?
    
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        
        collectionView?.refreshControl = refreshControl
        
        
        onViewIsAppearing = { vc in
            vc.load()
            vc.collectionView?.refreshControl?.addTarget(self, action: #selector(vc.load), for: .valueChanged)
            vc.onViewIsAppearing = nil
        }
    }

    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    @objc func load() {
        collectionView?.refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
}
