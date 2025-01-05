//
//  HTTPClient.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 05/11/24.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    func get(from: URL, completion: @escaping (Result) -> Void)
}
