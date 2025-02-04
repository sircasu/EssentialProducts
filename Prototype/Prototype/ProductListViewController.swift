//
//  ProductListViewController.swift
//  Prototype
//
//  Created by Matteo Casu on 19/01/25.
//

import UIKit

struct ProductListViewModel {
    let productImage: String
    let productName: String
    let productDescription: String
    let productPrice: String
}

class ProductListViewController: UICollectionViewController {
    
    let refreshControl = UIRefreshControl()
    private var onViewIsAppearing: ((ProductListViewController) -> Void)?
    private var products = [ProductListViewModel]()
    
    
    @IBAction public func refresh() {
        
        collectionView.refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.products.isEmpty {
                self.products = ProductListViewModel.prototypeProducts
                self.collectionView.reloadData()
            }
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = self.refreshControl
        
        onViewIsAppearing = { vc in

            vc.collectionView.refreshControl?.addTarget(vc, action: #selector(vc.refresh), for: .valueChanged)
            vc.refresh()
            vc.onViewIsAppearing = nil
        }
        
        let listLayout = UICollectionViewFlowLayout()
        listLayout.itemSize = CGSize(width: collectionView.frame.size.width, height: 200)
        listLayout.minimumLineSpacing = 1
        listLayout.minimumInteritemSpacing = 0
        collectionView?.setCollectionViewLayout(listLayout, animated: false)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListItemCell", for: indexPath) as! ProductListItemCell
        
        cell.backgroundColor = .white
        cell.configure(with: products[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        if let cell = cell as? ProductListItemCell {
            cell.fadeIn(products[indexPath.row].productImage)
        }

    }
    
}

