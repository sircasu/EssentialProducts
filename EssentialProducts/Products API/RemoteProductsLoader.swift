//
//  RemoteProductsLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from: URL, completion: @escaping (Result) -> Void)
}

final public class RemoteProductsLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ProductItem], Error>
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case let .success((data, response)):
                do {
                    let items = try ProductItemMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }

            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


private class ProductItemMapper {
    
    private struct RemoteProductItem: Decodable {
        let id: Int
        let title: String
        let price: Double
        let description: String
        let category: String
        let image: URL
        let rating: RemoteProductRatingItem

        var toItems: ProductItem {
            ProductItem(id: id, title: title, price: price, description: description, category: category, image: image, rating: ProductRatingItem(rate: rating.rate, count: rating.count))
        }
    }

    private struct RemoteProductRatingItem: Decodable {
        let rate: Double
        let count: Int
        
        init(rate: Double, count: Int) {
            self.rate = rate
            self.count = count
        }
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ProductItem] {
        
        guard response.statusCode == OK_200 else { throw RemoteProductsLoader.Error.invalidData }
        
        return try JSONDecoder().decode([RemoteProductItem].self, from: data).map { $0.toItems }
    }
}
