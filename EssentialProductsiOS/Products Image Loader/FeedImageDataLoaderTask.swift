//
//  FeedImageDataLoaderTask.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 06/02/25.
//

import Foundation

public protocol ProductImageDataLoaderTask {
    func cancel()
}

public protocol ProductImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ProductImageDataLoaderTask
}
