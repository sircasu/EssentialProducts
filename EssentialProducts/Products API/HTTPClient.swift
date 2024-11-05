//
//  HTTPClient.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 05/11/24.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from: URL, completion: @escaping (Result) -> Void)
}
