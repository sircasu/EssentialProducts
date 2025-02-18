//
//  ProductItemCellController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit

protocol ProductItemCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class ProductItemCellController: ProductImageView {
    

    private let delegate: ProductItemCellControllerDelegate
    private lazy var cell = ProductItemCell()

    init(delegate: ProductItemCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UICollectionViewCell {
    
        delegate.didRequestImage()
        return cell
    }
    
    func display(viewModel: ProductImagePresenterViewModel) {
        
        cell.productNameLabel.text = viewModel.name
        cell.productDescriptionLabel.text = viewModel.description
        cell.productPriceLabel.text = viewModel.price
        cell.productImageView.image = viewModel.image
        cell.onRetry = delegate.didRequestImage
        cell.productContainerImageView.isShimmering = viewModel.isLoading
        cell.productImageRetryButton.isHidden = !viewModel.shouldRetry
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancel() {
        delegate.didCancelImageRequest()
    }
}
