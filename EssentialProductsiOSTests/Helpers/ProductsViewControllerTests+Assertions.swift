//
//  ProductsViewControllerTests+Assertions.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 06/02/25.
//

import XCTest
import EssentialProducts
import EssentialProductsiOS

extension ProductsViewControllerTests {
    func assertThat(_ sut: ProductsViewController, isRendering products: [ProductItem], file: StaticString = #filePath, line: UInt = #line) {
        
        guard sut.numberOfRenderedProductViews() == products.count else {
            return XCTFail("Expected \(products.count) products, got \(sut.numberOfRenderedProductViews()) instead", file: file, line: line)
        }
        
        products.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
     
    func assertThat(_ sut: ProductsViewController, hasViewConfiguredFor product: ProductItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        
        let view = sut.productView(at: index)
        
        guard let cell = view as? ProductItemCell else {
            return XCTFail("Expected \(ProductItemCell.self), got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(cell.productName, product.title, "Expected product name to be \(String(describing: product.title)) for product view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.productDescription, product.description, "Expected product description to be \(String(describing: product.description)) for product view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.productPrice, String(product.price), "Expected product price to be \(String(describing: product.price)) for product view at index \(index)", file: file, line: line)
    }
}
