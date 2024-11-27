//
//  RemoteProductsLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

final public class RemoteProductsLoader: ProductsLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = ProductsLoader.Result
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                do {
                    let items = try ProductItemMapper.map(data, response)
                    completion(.success(items.toModels()))
                } catch {
                    completion(.failure(error))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

extension Array where Element == RemoteProductItem {
    func toModels() -> [ProductItem] {
        map { ProductItem(id: $0.id, title: $0.title, price: $0.price, description: $0.description, category: $0.category, image: $0.image, rating: ProductRatingItem(rate: $0.rating.rate, count: $0.rating.count)) }
    }
}
