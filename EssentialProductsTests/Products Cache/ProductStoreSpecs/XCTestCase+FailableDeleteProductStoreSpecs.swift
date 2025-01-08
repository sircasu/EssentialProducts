//
//  XCTestCase+FailableDeleteProductStoreSpecs.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import XCTest
import EssentialProducts

extension FailableDeleteProductStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
  
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
