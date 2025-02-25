//
//  ProductsUIComposer.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 07/02/25.
//

import Foundation
import EssentialProducts
import UIKit

public final class ProductsUIComposer {
    private init() {}
    
    public static func productsComposedWith(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) -> ProductsViewController {
        
        
        let presentationAdapter = ProductsLoaderPresentationAdapter(productsLoader: MainQueueDispatchDecorator(decoratee: productsLoader))
        let refreshController = ProductRefreshViewController(delegate: presentationAdapter)
        
        let productsViewController = ProductsViewController.makeWith(refreshController: refreshController, title: ProductsPresenter.title)
        
        let productsViewAdapter = ProductsViewAdapter(
            controller: productsViewController,
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        
        let presenter = ProductsPresenter(
            productsLoadingView: WeakReferenceVirtualProxy(refreshController),
            productsView: productsViewAdapter,
            productsErrorView: productsViewAdapter
        )
        presentationAdapter.presenter = presenter
        
        return productsViewController
    }
}

private extension ProductsViewController {
    static func makeWith(refreshController: ProductRefreshViewController, title: String) -> ProductsViewController {
        
        let storyboard = UIStoryboard(name: "Products", bundle: Bundle(for: ProductsViewController.self))
        let productsViewController = storyboard.instantiateInitialViewController(creator: { coder in
            
            return ProductsViewController(
                coder: coder,
                refreshController: refreshController)
        })!
        
        productsViewController.title = title
        
        return productsViewController
    }
}


private final class ProductsViewAdapter: ProductsView, ProductsErrorView {
    
    private weak var controller: ProductsViewController?
    var imageLoader: ProductImageDataLoader
    
    init(controller: ProductsViewController, imageLoader: ProductImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: ProductsViewModel) {
        controller?.collectionModel = viewModel.products.map { product in
            
            let adapter = ProductsImageDataLoaderAdapter<WeakReferenceVirtualProxy<ProductItemCellController>, UIImage>(model: product, imageLoader: imageLoader)
            
            let cell = ProductItemCellController(delegate: adapter)
            
            let presenter = ProductImagePresenter(view: WeakReferenceVirtualProxy(cell), imageTransformer: UIImage.init)
            
            adapter.presenter = presenter
            
            return cell
        }
    }
    
    func display(_ viewModel: ProductsErrorViewModel) {
        if let message = viewModel.message {
            controller?.errorView.message = message
            return
        }
        
        controller?.errorView.message = nil
    }
}


private final class WeakReferenceVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakReferenceVirtualProxy: ProductsLoadingView where T: ProductsLoadingView {
    
    func display(_ viewModel: ProductsLoadingViewModel) {
        object?.display(viewModel)
    }
    
}

extension WeakReferenceVirtualProxy: ProductImageView where T: ProductImageView, T.Image == UIImage {
    
    func display(viewModel: ProductImageViewModel<UIImage>) {
        object?.display(viewModel: viewModel)
    }
}


final class ProductsLoaderPresentationAdapter: ProductRefreshViewControllerDelegate {
    
    
    private let productsLoader: ProductsLoader
    var presenter: ProductsPresenter?
    
    init(productsLoader: ProductsLoader) {
        self.productsLoader = productsLoader
    }
    
    func didRequestProductsRefresh() {
        
        presenter?.didStartLoadingProducts()
        
        productsLoader.load { [weak self] result in
            switch result {
            case let .success(products):
                self?.presenter?.didFinishLoadingProducts(with: products)
            case .failure:
                self?.presenter?.didFinishLoadingProductsWithError()
            }
        }
        
    }
}


final class ProductsImageDataLoaderAdapter<View: ProductImageView, Image>: ProductItemCellControllerDelegate where View.Image == Image {
    
    
    private var task: ProductImageDataLoaderTask?
    private var model: ProductItem
    private let imageLoader: ProductImageDataLoader
    
    var presenter: ProductImagePresenter<View, Image>?
    
    init(model: ProductItem, imageLoader: ProductImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingProductsData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.image) { [weak self] result in
            switch result {
            case let .success(imageData):
                self?.presenter?.didFinishLoadingImageData(with: imageData, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
    
}
