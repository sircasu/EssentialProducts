//
//  ProductsViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 05/02/25.
//

import UIKit
import EssentialProducts

public final class ProductsViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    
    public var refreshController: ProductRefreshViewController?
    private var imageLoader: ProductImageDataLoader?
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    private var collectionModel = [ProductItem]() {
        didSet { collectionView.reloadData() }
    }
    private var cellControllers = [IndexPath: ProductItemCellViewController]()
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) {
        self.init()
        self.refreshController = ProductRefreshViewController(productsLoader: productsLoader)
        self.imageLoader = imageLoader
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        refreshController?.onRefresh = { [weak self] products in
            self?.collectionModel = products
        }
        
        collectionView?.refreshControl = refreshController?.view
        collectionView?.prefetchDataSource = self
        
        onViewIsAppearing = { [weak self] vc in
            guard let self = self else { return }
            refreshController?.refresh()
            vc.onViewIsAppearing = nil
        }
    }

    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
        
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return cellController(forRowAt: indexPath).view()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        removeCellController(forRowAt: indexPath)
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ProductItemCellViewController {
        let cellModel = collectionModel[indexPath.row]
        let cellController = ProductItemCellViewController(model: cellModel, imageLoader: imageLoader)
        cellControllers[indexPath] = cellController
        
        return cellController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
