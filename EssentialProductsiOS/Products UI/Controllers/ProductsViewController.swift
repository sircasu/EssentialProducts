//
//  ProductsViewController.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 05/02/25.
//

import UIKit

public final class ErrorHeaderView: UICollectionReusableView {
    
    @IBOutlet public weak var message: UILabel!
}


public final class ProductsViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching, ProductsErrorView {
    
    public var errorView: ErrorHeaderView? = nil
    
    public var refreshController: ProductRefreshViewController?
    private var onViewIsAppearing: ((ProductsViewController) -> Void)?
    var collectionModel = [ProductItemCellController]() {
        didSet { collectionView.reloadData() }
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    init?(coder: NSCoder, refreshController: ProductRefreshViewController) {
        super.init(coder: coder)
        self.refreshController = refreshController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let productItemCell = String(describing: ProductItemCell.self)
        collectionView.register(UINib(nibName: productItemCell, bundle: Bundle(for: ProductItemCell.self)), forCellWithReuseIdentifier: productItemCell)
//        
//        let errorHeaderViewId = String(describing: ErrorHeaderView.self)
//        collectionView.register(ErrorHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ErrorHeaderView")
        
                
        collectionView?.refreshControl = refreshController?.view
        collectionView?.prefetchDataSource = self
        
        onViewIsAppearing = { [weak self] vc in
            guard let self = self else { return }
            refreshController?.refresh()
            vc.onViewIsAppearing = nil
        }
    }

    func display(_ viewModel: ProductsErrorViewModel) {
//        collectionView.layoutIfNeeded()
//        errorView.message = viewModel.message
        guard let headerView = errorView else { return }
        headerView.message.text = viewModel.message
    }
    
    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    
    
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return cellController(forRowAt: indexPath).view(in: collectionView, at: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cancelCellController(forRowAt: indexPath)
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach(cancelCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ProductItemCellController {
        return collectionModel[indexPath.row]
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancel()
    }
    
        //
    
//    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        if kind == UICollectionView.elementKindSectionHeader {
////            
//            let viewIdentifier = String(describing: ErrorHeaderView.self)
//            
//            let view = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: viewIdentifier,
//                for: indexPath) as! ErrorHeaderView
//            
//            view.message.text = "Prova OOOO header"
//            return view
//        }
//        return UICollectionReusableView()
//    }
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
     }
    
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
//                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ErrorHeaderView", for: indexPath) as! ErrorHeaderView
//                // Configure the header view
//                return headerView
                
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ErrorHeaderView", for: indexPath) as? ErrorHeaderView else {
                    // Handle the case where dequeueing failed (e.g., return a default view or log an error)
                    print("Failed to dequeue ErrorHeaderView")
                    return UICollectionReusableView() // Return an empty view, or another default view.
                }
                errorView = headerView
                return headerView
            }
            return UICollectionReusableView()
        }
}

//extension ProductsViewController: UICollectionViewDelegateFlowLayout {
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//       
//       return CGSize(width: collectionView.frame.width, height: 80)
//     }
//}
