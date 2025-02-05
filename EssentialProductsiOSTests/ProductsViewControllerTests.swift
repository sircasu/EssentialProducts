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

    func test_init_doesNotLoadProducts() {
        
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_viewDidLoad_loadProducts() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        
        sut.simulateAppareance()
        
        XCTAssertEqual(loader.callCount, 1)
    }
    
    func test_pullToRefresh_loadsProducts() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        
        sut.collectionView?.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.callCount, 2)
        
        sut.collectionView?.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.callCount, 3)
    }
    
    func test_viewdidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        
        sut.simulateAppareance()
 
        XCTAssertEqual(sut.collectionView?.refreshControl?.isRefreshing, true)
    }
    
    func test_viewdidLoad_hidesLoadingIndicatorOnLoadercompletion() {
        let (sut, loader) = makeSUT()
    
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        
        sut.simulateAppareance()
 
        XCTAssertEqual(sut.collectionView?.refreshControl?.isRefreshing, true)
        
        loader.completeProductsLoading()
        
        XCTAssertEqual(sut.collectionView?.refreshControl?.isRefreshing, false)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {

        let (sut, loader) = makeSUT()
    
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        loader.completeProductsLoading()
        
        sut.collectionView?.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(sut.collectionView?.refreshControl?.isRefreshing, true)
    }
    
    
    func test_pullToRefresh_hidesLoadingIndicatorOnLoadercompletion() {

        let (sut, loader) = makeSUT()
    
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFake()
        sut.simulateAppareance()
        loader.completeProductsLoading()
        
        sut.collectionView?.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(sut.collectionView?.refreshControl?.isRefreshing, true)
        
        loader.completeProductsLoading()
        XCTAssertEqual(sut.collectionView?.refreshControl?.isRefreshing, false)
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
}
