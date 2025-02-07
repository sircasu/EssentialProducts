//
//  ProducItemCell.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 05/02/25.
//

import UIKit


public final class ProductItemCell: UICollectionViewCell {
    public let productContainerImageView = UIView()
    public let productImageView = UIImageView()
    public let productNameLabel = UILabel()
    public let productDescriptionLabel = UILabel()
    public let productPriceLabel = UILabel()
    
    private(set) public lazy var productImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
