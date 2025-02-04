//
//  ProductListItemCell.swift
//  Prototype
//
//  Created by Matteo Casu on 04/02/25.
//

import UIKit

class ProductListItemCell: UICollectionViewCell {
    @IBOutlet weak var productContainerImageView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        productImageView.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        productImageView.alpha = 0
    }

    public func fadeIn(_ image: String) {

        productImageView.image = UIImage(named: image)

        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.productImageView.alpha = 1
            })
    }
    
    public func configure(with viewModel: ProductListViewModel) {
        productNameLabel.text = viewModel.productName
        productDescriptionLabel.text = viewModel.productDescription
        productPriceLabel.text = viewModel.productPrice
    }
}
