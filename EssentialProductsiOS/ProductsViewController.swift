//
//  ProductsViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 05/02/25.
//

import UIKit
import EssentialProducts

public protocol ProductImageDataLoaderTask {
    func cancel()
}

public protocol ProductImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ProductImageDataLoaderTask
}

final public class ProductsViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    
    private var productsLoader: ProductsLoader?
    private var imageLoader: ProductImageDataLoader?
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    private var collectionModel = [ProductItem]()
    private var tasks = [IndexPath: ProductImageDataLoaderTask]()
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) {
        self.init()
        self.productsLoader = productsLoader
        self.imageLoader = imageLoader
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        
        collectionView?.refreshControl = refreshControl
        collectionView?.prefetchDataSource = self
        
        onViewIsAppearing = { [weak self] vc in
            guard let self = self else { return }
            vc.load()
            vc.collectionView?.refreshControl?.addTarget(self, action: #selector(vc.load), for: .valueChanged)
            vc.onViewIsAppearing = nil
        }
    }

    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    @objc func load() {
        collectionView?.refreshControl?.beginRefreshing()
        productsLoader?.load { [weak self] result in
            
            if let products = try? result.get() {
                self?.collectionModel = products
                self?.collectionView?.reloadData()
            }
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellModel = collectionModel[indexPath.row]
        let cell = ProductItemCell()
        cell.productNameLabel.text = cellModel.title
        cell.productDescriptionLabel.text = cellModel.description
        cell.productPriceLabel.text = String(cellModel.price)
        cell.productContainerImageView.isShimmering = true
        cell.productImageView.image = nil
        cell.productImageRetryButton.isHidden = true

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.image) { [weak cell] result in
                
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
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cancelTask(forRowAt: indexPath)
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            let cellModel = collectionModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.image) { _ in }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
        
    }
}
