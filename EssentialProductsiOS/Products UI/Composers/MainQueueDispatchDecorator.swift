//
//  MainQueueDispatchDecorator.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 24/02/25.
//

import Foundation
import EssentialProducts

final class MainQueueDispatchDecorator<T>  {
    
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async {
                completion()
            }
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: ProductsLoader where T == ProductsLoader {
    
    func load(completion: @escaping (ProductsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: ProductImageDataLoader where T == ProductImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (ProductImageDataLoader.Result) -> Void) -> ProductImageDataLoaderTask {
        
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
