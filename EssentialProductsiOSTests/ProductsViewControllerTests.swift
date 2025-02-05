//
//  ProductsViewControllerTests.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 05/02/25.
//

import XCTest
import UIKit
import EssentialProducts

final class ProductsViewController: UICollectionViewController {
    
    private var loader: ProductsLoader?
    
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        
        collectionView?.refreshControl = refreshControl
        
        
        onViewIsAppearing = { vc in
            vc.load()
            vc.collectionView?.refreshControl?.addTarget(self, action: #selector(vc.load), for: .valueChanged)
            vc.onViewIsAppearing = nil
        }
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    @objc func load() {
        collectionView?.refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
}

final class ProductsViewControllerTests: XCTestCase {

    func test_loadProductActions_requestProductsFromLoader() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0, "Expected no loading requests before view is appearing")
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        XCTAssertEqual(loader.callCount, 1, "Expected q loading requests once view is appeared")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.callCount, 2, "Expected another loading requests once user initiates reload")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertEqual(loader.callCount, 3, "Expected a third loading requests once user initiates another reload")
    }
    
    func test_loadProductIndicator_isVisibleWhenLoadingProducts() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        
        sut.simulateAppareance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeProductsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once view loading is completed")
        
        sut.simulateUserInitiatedProductsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initated reload")
        
        loader.completeProductsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initated reload is complete")
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ProductsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ProductsViewController(loader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: ProductsLoader {
        
        var messages: [(ProductsLoader.Result) -> Void] = [(ProductsLoader.Result) -> Void]()
        
        var callCount: Int { messages.count }
        
        func load(completion: @escaping (ProductsLoader.Result) -> Void) {
            messages.append(completion)
        }
        
        func completeProductsLoading(at index: Int = 0) {
            messages[index](.success([]))
        }
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

private extension ProductsViewController {
    
    func simulateAppareance() {
        beginAppearanceTransition(true, animated: false) // viewWillAppear
        endAppearanceTransition() // viewIsAppearing + viewDidAppear
    }
    
    func replaceRefreshControlWithFake() {
        
        let fakeRefreshControl = FakeRefreshControl()
        
        fakeRefreshControl.simulatePullToRefresh()
        
        collectionView?.refreshControl = fakeRefreshControl
    }
    
    func simulateUserInitiatedProductsReload() {
        collectionView?.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return collectionView?.refreshControl?.isRefreshing == true
    }
}
