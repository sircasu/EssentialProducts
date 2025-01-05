//
//  ProductStoreSpecs.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 05/01/25.
//

import Foundation

protocol ProductStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesExistingCache()
    
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_leavesCacheEmptyOnNonEmptyCache()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveProductStoreSpecs: ProductStoreSpecs {
    func test_retrieve_deliversErrorOnInvalidData()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertProductStoreSpecs: ProductStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteProductStoreSpecs: ProductStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectOnDeletionError()
}

typealias FailableProductStoreSpecs = FailableDeleteProductStoreSpecs & FailableInsertProductStoreSpecs & FailableRetrieveProductStoreSpecs
