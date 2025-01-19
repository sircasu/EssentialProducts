//
//  ProductListViewController.swift
//  Prototype
//
//  Created by Matteo Casu on 19/01/25.
//

import UIKit

class ProductListItemCell: UICollectionViewCell {
    @IBOutlet weak var productContainerImageView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
}


class ProductListViewController: UICollectionViewController {
    
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
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListItemCell", for: indexPath)
        
        cell.backgroundColor = .white
        
        return cell
    }
    
}

