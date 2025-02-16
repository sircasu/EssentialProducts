//
//  ProductItemCellController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit

final class ProductItemCellController: ProductImageView {
    
    private let presenter: ProductImagePresenter
    private lazy var cell = ProductItemCell()

    init(presenter: ProductImagePresenter) {
        self.presenter = presenter
    }
    
    func view() -> UICollectionViewCell {
    
        presenter.loadImageData()
        return cell
    }
    
    func display(viewModel: ProductImagePresenterViewModel) {
        
        cell.productNameLabel.text = viewModel.name
        cell.productDescriptionLabel.text = viewModel.description
        cell.productPriceLabel.text = viewModel.price
        cell.productImageView.image = viewModel.image
        cell.onRetry = presenter.loadImageData
        cell.productContainerImageView.isShimmering = viewModel.isLoading
        cell.productImageRetryButton.isHidden = !viewModel.shouldRetry
    }
    
    func preload() {
        presenter.loadImageData()
    }
    
    func cancel() {
        presenter.cancel()
    }
}
