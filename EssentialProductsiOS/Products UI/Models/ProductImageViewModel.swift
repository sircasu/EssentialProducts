//
//  ProductImageViewModel.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 12/02/25.
//

import UIKit
import EssentialProducts

public final class ProductImageViewModel {
    typealias Observer<T> = (T) -> Void

    private var task: ProductImageDataLoaderTask?
    private let model: ProductItem
    private let imageLoader: ProductImageDataLoader?
    
    var productName: String? { model.title }
    var productDescription: String? { model.description }
    var productPrice: String? { String(model.price) }
    
    init(model: ProductItem, imageLoader: ProductImageDataLoader?) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        
        onImageLoadStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader?.loadImageData(from: model.image) { [weak self] result in
            
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            if let image = image {
                self?.onImageLoad?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadStateChange?(false)
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}
