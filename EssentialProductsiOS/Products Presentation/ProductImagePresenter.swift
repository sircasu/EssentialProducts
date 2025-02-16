//
//  ProductImagePresenter.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 15/02/25.
//

import Foundation
import UIKit
import EssentialProducts

struct ProductImagePresenterViewModel {
    var name: String
    var description: String
    var price: String
    var image: UIImage?
    var isLoading: Bool
    var shouldRetry: Bool
}

protocol ProductImageView {
    func display(viewModel: ProductImagePresenterViewModel)
}

public final class ProductImagePresenter {

    private var task: ProductImageDataLoaderTask?
    private var model: ProductItem
    private let imageLoader: ProductImageDataLoader?
    
    var view: ProductImageView?
    
    init(model: ProductItem, imageLoader: ProductImageDataLoader ) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func loadImageData() {

        var viewModel = ProductImagePresenterViewModel(
            name: model.title,
            description: model.description,
            price: String(model.price),
            image: nil,
            isLoading: true,
            shouldRetry: false)
        
        view?.display(viewModel: viewModel)
        
        self.task = self.imageLoader?.loadImageData(from: model.image) { [weak self] result in
            
            guard let self = self else { return }
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
  
            if let image = image {
                viewModel.image = image
                viewModel.isLoading = false
                viewModel.shouldRetry = false
            } else {
                viewModel.image = nil
                viewModel.isLoading = false
                viewModel.shouldRetry = true
            }
            
            view?.display(viewModel: viewModel)
        }
        
    }
    
    func cancel() {
        task?.cancel()
    }
}
