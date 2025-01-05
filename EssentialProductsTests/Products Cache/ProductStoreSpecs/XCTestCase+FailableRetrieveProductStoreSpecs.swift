//
//  XCTestCase+FailableRetrieveProductStoreSpecs.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import XCTest
import EssentialProducts

extension FailableRetrieveProductStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversErrorOnInvalidData(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }
  
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: ProductStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
