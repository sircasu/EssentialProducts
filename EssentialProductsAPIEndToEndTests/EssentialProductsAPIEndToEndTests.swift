//
//  EssentialProductsAPIEndToEndTests.swift
//  EssentialProductsAPIEndToEndTests
//
//  Created by Matteo Casu on 09/11/24.
//

import XCTest
import EssentialProducts

final class EssentialProductsAPIEndToEndTests: XCTestCase {
    
    func test_endToEndServerGETProducts_matchesFixedTestData() {
        
        let productsResult = getProductsResult()
        
        switch productsResult {
        case let .success(products):
            XCTAssertEqual(products.count, 3, "Expected 3 products, got \(products.count) instead")
            XCTAssertEqual(products[0], expectedItem(at: 0))
            XCTAssertEqual(products[1], expectedItem(at: 1))
            XCTAssertEqual(products[2], expectedItem(at: 2))
        case let .failure(error):
            XCTFail("Unexpected error: \(error)")
        default: XCTFail("Expected result got nothing instead")
        }
    }
    
    
    // MARK: Helpers
    
    private func getProductsResult(file: StaticString = #filePath, line: UInt = #line) -> ProductsLoader.Result? {
        let serverURL = URL(string: "https://fakestoreapi.com/products?limit=3")!
        let client = URLSessionHTTPClient()
        let loader = RemoteProductsLoader(client: client, url: serverURL)
        
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for loading completion")
        
        var receivedResult: ProductsLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3)
        return receivedResult
    }
    
    
    func id(at index: Int) -> Int {
        return [1, 2, 3][index]
    }
    
    func title(at index: Int) -> String {
        return [
            "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
            "Mens Casual Premium Slim Fit T-Shirts ",
            "Mens Cotton Jacket"
        ][index]
    }
    
    func price(at index: Int) -> Double {
        return [
            109.95,
            22.3,
            55.99
        ][index]
    }
    
    func description(at index: Int) -> String {
        return [
            "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
            "Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing. And Solid stitched shirts with round neck made for durability and a great fit for casual fashion wear and diehard baseball fans. The Henley style round neckline includes a three-button placket.",
            "great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions, such as working, hiking, camping, mountain/rock climbing, cycling, traveling or other outdoors. Good gift choice for you or your family member. A warm hearted love to Father, husband or son in this thanksgiving or Christmas Day."
        ][index]
    }
    
    func category(at index: Int) -> String {
        return [
            "men's clothing",
            "men's clothing",
            "men's clothing"
        ][index]
    }
        
    func image(at index: Int) -> URL {
        return [
            URL(string: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg")!,
            URL(string: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg")!,
            URL(string: "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg")!
        ][index]
    }
         
    func rating(at index: Int) -> ProductRatingItem {
        return [
            ProductRatingItem(rate: 3.9, count: 120),
            ProductRatingItem(rate: 4.1, count: 259),
            ProductRatingItem(rate: 4.7, count: 500)
        ][index]
    }
    
    func expectedItem(at index: Int) -> ProductItem {
        ProductItem(
            id: id(at: index),
            title: title(at: index),
            price: price(at: index),
            description: description(at: index),
            category: category(at: index),
            image: image(at: index),
            rating: rating(at: index))
    }
}
