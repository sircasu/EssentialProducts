//
//  ProductImagePresenter.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 15/02/25.
//

import Foundation
import EssentialProducts

protocol ProductImageView {
    associatedtype Image
    func display(viewModel: ProductImageViewModel<Image>)
}

final class ProductImagePresenter<View: ProductImageView, Image> where View.Image == Image {

    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingProductsData(for model: ProductItem) {
        let viewModel = ProductImageViewModel<Image>(
            name: model.title,
            description: model.description,
            price: String(model.price),
            image: nil,
            isLoading: true,
            shouldRetry: false)

        view.display(viewModel: viewModel)
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with imageData: Data, for model: ProductItem) {
        guard let image = imageTransformer(imageData) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        let viewModel = ProductImageViewModel<Image>(
            name: model.title,
            description: model.description,
            price: String(model.price),
            image: image,
            isLoading: false,
            shouldRetry: false)

        view.display(viewModel: viewModel)
    }
    
    func didFinishLoadingImageData(with: Error, for model: ProductItem) {
        let viewModel = ProductImageViewModel<Image>(
            name: model.title,
            description: model.description,
            price: String(model.price),
            image: nil,
            isLoading: false,
            shouldRetry: true)

        view.display(viewModel: viewModel)
    }
}
