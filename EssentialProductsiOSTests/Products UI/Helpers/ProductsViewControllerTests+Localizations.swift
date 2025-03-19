//
//  ProductsViewControllerTests+Localizations.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 23/02/25.
//

import Foundation
import XCTest
import EssentialProducts

extension ProductsUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        
        let table = "Products"
        let bundle = Bundle(for: ProductsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key:  \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}

