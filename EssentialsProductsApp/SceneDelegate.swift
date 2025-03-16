//
//  SceneDelegate.swift
//  EssentialsProductsApp
//
//  Created by Matteo Casu on 06/03/25.
//

import UIKit
import EssentialProducts
import EssentialProductsiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = .init(windowScene: windowScene)
        
        window?.rootViewController = ProductsUIComposer.productsComposedWith(productsLoader: MockLoader(), imageLoader: LoaderSpy())
        window?.makeKeyAndVisible()
        
    }



}


class MockLoader: ProductsLoader {
    func load(completion: @escaping (ProductsLoader.Result) -> Void) {
        
        let elements: [ProductItem] = [
            ProductItem(id: 1, title: "a title", price: 12.34, description: "a description", category: "a category", image: URL(string: "https://via.placeholder.com/150")!, rating: ProductRatingItem(rate: 4.5, count: 98))
        ]
        
        completion(.success(elements))
    }
    
    
}





extension SceneDelegate {
    
    func anyURL() -> URL {
        return URL(string: "https://example.com/")!
    }

    func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
    
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
        
        func completeProductLoadingWithError(_ error: Error =  NSError(domain: "test", code: 0), at index: Int = 0) {
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
            loadImageRequests[index].completion(.failure( NSError(domain: "test", code: 0)))
        }
    }
}
