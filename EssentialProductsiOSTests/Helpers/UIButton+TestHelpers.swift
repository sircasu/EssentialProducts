//
//  UIButton+TestHelpers.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 06/02/25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
