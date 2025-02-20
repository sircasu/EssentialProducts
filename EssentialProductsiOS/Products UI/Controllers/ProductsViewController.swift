//
//  ProductsViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 05/02/25.
//

import UIKit

public final class ProductsViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    
    public var refreshController: ProductRefreshViewController?
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    var collectionModel = [ProductItemCellController]() {
        didSet { collectionView.reloadData() }
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    init?(coder: NSCoder, refreshController: ProductRefreshViewController) {
        super.init(coder: coder)
        self.refreshController = refreshController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
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

        return cellController(forRowAt: indexPath).view(in: collectionView, at: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cancelCellController(forRowAt: indexPath)
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach(cancelCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ProductItemCellController {
        return collectionModel[indexPath.row]
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancel()
    }
}
