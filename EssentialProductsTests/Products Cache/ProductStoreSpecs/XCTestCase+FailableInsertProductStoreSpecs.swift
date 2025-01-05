//
//  XCTestCase+FailableInsertProductStoreSpecs.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import XCTest
import EssentialProducts

extension FailableInsertProductStoreSpecs where Self: XCTestCase {
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        let products = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((products, timestamp: timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected error", file: file, line: line)
    }
  
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let products = uniqueItems().local
        let timestamp = Date()
        
        insert((products, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .empty)
    }
}
