//
//  UICollectionView+Dequeuing.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 21/02/25.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }
}

