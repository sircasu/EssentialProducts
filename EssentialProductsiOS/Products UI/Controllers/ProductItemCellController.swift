//
//  ProductItemCellController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit

final class ProductItemCellController {
    private let viewModel: ProductImageViewModel<UIImage>
    
    init(viewModel: ProductImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UICollectionViewCell {
        
        let cell = bind(ProductItemCell())
        viewModel.loadImageData()
        return cell
    }
    
    func bind(_ cell: ProductItemCell) -> ProductItemCell {
        
        cell.productNameLabel.text = viewModel.productName
        cell.productDescriptionLabel.text = viewModel.productDescription
        cell.productPriceLabel.text = viewModel.productPrice
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.productImageView.image = image
        }
        
        viewModel.onImageLoadStateChange = { [weak cell] isLoading in
            cell?.productContainerImageView.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
    
            cell?.productImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancel() {
        viewModel.cancel()
    }
}
