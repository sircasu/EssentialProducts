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
    private var cell: ProductItemCell?

    init(delegate: ProductItemCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(for: indexPath)
        delegate.didRequestImage()
        return cell!
    }
    
    func display(viewModel: ProductImageViewModel<UIImage>) {
        
        cell?.productNameLabel.text = viewModel.name
        cell?.productDescriptionLabel.text = viewModel.description
        cell?.productPriceLabel.text = viewModel.price
        cell?.productImageView.setImageAnimated(viewModel.image)
        cell?.productContainerImageView.isShimmering = viewModel.isLoading
        cell?.productImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancel() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
