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
    
    public func configure(with viewModel: ProductListViewModel) {
        productImageView.image = UIImage(named: viewModel.productImage)
        productNameLabel.text = viewModel.productName
        productDescriptionLabel.text = viewModel.productDescription
        productPriceLabel.text = viewModel.productPrice
    }
}

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
    
}

