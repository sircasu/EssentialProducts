//
//  URLSessionHTTPClient.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 09/11/24.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    private struct UnexpectedError: Error {}
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        
        session.dataTask(with: url) { data, response, error in
            
            completion( Result {
                if let error = error {
                   throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedError()
                }
            })
            
//            if let error = error {
//                completion(.failure(error))
//            } else if let data = data, let response = response as? HTTPURLResponse {
//                completion(.success((data, response)))
//            } else {
//                completion(.failure(UnexpectedError()))
//            }
        }.resume()
    }
}
