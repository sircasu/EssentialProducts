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
    
    let viewModel = ProductListViewModel.prototypeProducts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listLayout = UICollectionViewFlowLayout()
        listLayout.itemSize = CGSize(width: collectionView.frame.size.width, height: 200)
        listLayout.minimumLineSpacing = 1
        listLayout.minimumInteritemSpacing = 0
        collectionView?.setCollectionViewLayout(listLayout, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListItemCell", for: indexPath) as! ProductListItemCell
        
        cell.backgroundColor = .white
        cell.configure(with: viewModel[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        if let cell = cell as? ProductListItemCell {
            cell.fadeIn(viewModel[indexPath.row].productImage)
        }

    }
    
}

