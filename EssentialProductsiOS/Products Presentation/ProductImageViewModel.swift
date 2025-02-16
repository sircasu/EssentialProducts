//
//  ProductImageViewModel.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 12/02/25.
//

import EssentialProducts

public final class ProductImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void

    private var task: ProductImageDataLoaderTask?
    private let model: ProductItem
    private let imageLoader: ProductImageDataLoader?
    private let imageTransformer: (Data) -> Image?
    
    var productName: String? { model.title }
    var productDescription: String? { model.description }
    var productPrice: String? { String(model.price) }
    
    init(model: ProductItem, imageLoader: ProductImageDataLoader?, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        
        onImageLoadStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader?.loadImageData(from: model.image) { [weak self] result in
            
            guard let self = self else { return }
            let data = try? result.get()
            let image = data.map(self.imageTransformer) ?? nil
            if let image = image {
                self.onImageLoad?(image)
            } else {
                self.onShouldRetryImageLoadStateChange?(true)
            }
            self.onImageLoadStateChange?(false)
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}
