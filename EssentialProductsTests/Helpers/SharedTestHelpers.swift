//
//  SharedTestHelpers.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 09/12/24.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://example.com/")!
}

func anyNSError() -> NSError {
    return NSError(domain: "test", code: 0)
}
