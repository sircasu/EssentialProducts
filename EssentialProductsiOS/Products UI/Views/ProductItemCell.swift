//
//  ProductItemCell.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 21/02/25.
//

import UIKit

public final class ProductItemCell: UICollectionViewCell {

    @IBOutlet private(set) public var productContainerImageView: UIView!
    @IBOutlet private(set) public var productImageView: UIImageView!
    @IBOutlet private(set) public var productNameLabel: UILabel!
    @IBOutlet private(set) public var productDescriptionLabel: UILabel!
    @IBOutlet private(set) public var productPriceLabel: UILabel!
    @IBOutlet private(set) public var productImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
}
