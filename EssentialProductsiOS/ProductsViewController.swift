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
    private var collectionModel = [ProductItem]()
    
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
        
        onViewIsAppearing = { [weak self] vc in
            guard let self = self else { return }
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
        loader?.load { [weak self] result in
            
            if let products = try? result.get() {
                self?.collectionModel = products
                self?.collectionView?.reloadData()
            }
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellModel = collectionModel[indexPath.row]
        let cell = ProductItemCell()
        cell.productNameLabel.text = cellModel.title
        cell.productDescriptionLabel.text = cellModel.description
        cell.productPriceLabel.text = String(cellModel.price)
        return cell
    }
}
