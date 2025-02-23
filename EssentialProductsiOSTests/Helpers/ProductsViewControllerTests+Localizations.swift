//
//  ProductsViewControllerTests+Localizations.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 23/02/25.
//

import Foundation
import XCTest
import EssentialProductsiOS

extension ProductsViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        
        let table = "Products"
        let bundle = Bundle(for: ProductsViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key:  \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}

