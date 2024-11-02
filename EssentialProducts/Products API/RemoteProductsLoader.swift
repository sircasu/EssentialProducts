//
//  RemoteProductsLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<HTTPURLResponse, Error>
    func get(from: URL, completion: @escaping (Result) -> Void)
}

final public class RemoteProductsLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
