//
//  ProductItemCellViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import UIKit
import EssentialProducts

final class ProductItemCellViewController {
    private var task: ProductImageDataLoaderTask?
    private let model: ProductItem
    private let imageLoader: ProductImageDataLoader?
    
    init(model: ProductItem, imageLoader: ProductImageDataLoader?) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UICollectionViewCell {
        
        let cell = ProductItemCell()
        cell.productNameLabel.text = model.title
        cell.productDescriptionLabel.text = model.description
        cell.productPriceLabel.text = String(model.price)
        cell.productContainerImageView.isShimmering = true
        cell.productImageView.image = nil
        cell.productImageRetryButton.isHidden = true

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader?.loadImageData(from: model.image) { [weak cell] result in
                
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.productImageView.image = image
                cell?.productImageRetryButton.isHidden = (image != nil)

                cell?.productContainerImageView.isShimmering = false
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader?.loadImageData(from: model.image) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
