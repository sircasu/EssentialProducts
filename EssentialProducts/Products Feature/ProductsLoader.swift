//
//  ProductsLoader.swift
//  EssentialProducts
//
//  Created by Matteo Casu on 01/11/24.
//

import Foundation

public protocol ProductsLoader {
    typealias Result = Swift.Result<[ProductItem], Error>
    func load(completion: @escaping (Result) -> Void)
}
