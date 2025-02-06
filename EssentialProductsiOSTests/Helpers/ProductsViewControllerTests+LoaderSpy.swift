//
//  ProductsViewControllerTests+LoaderSpy.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 06/02/25.
//

import Foundation
import EssentialProducts
import EssentialProductsiOS

extension ProductsViewControllerTests {
    
    class LoaderSpy: ProductsLoader, ProductImageDataLoader {
        
        // MARK: - ProductsLoader
        
        private var productsRequests: [(ProductsLoader.Result) -> Void] = [(ProductsLoader.Result) -> Void]()
                
        var loadProductCallCount: Int { productsRequests.count }
        
        func load(completion: @escaping (ProductsLoader.Result) -> Void) {
            productsRequests.append(completion)
        }
        
        func completeProductsLoading(with products: [ProductItem] = [], at index: Int = 0) {
            productsRequests[index](.success(products))
        }
        
        func completeProductLoadingWithError(_ error: Error = anyNSError(), at index: Int = 0) {
            productsRequests[index](.failure(error))
        }
        
        // MARK: - ProductImageDataLoader
        
        private struct TaskSpy: ProductImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var loadImageRequests = [(url: URL, completion: (ProductImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            loadImageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs: [URL] = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) -> ProductImageDataLoaderTask {
            loadImageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            loadImageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            loadImageRequests[index].completion(.failure(anyNSError()))
        }
    }
}
