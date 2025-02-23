//
//  ProductItemCell+TestHelpers.swift
//  EssentialProductsiOSTests
//
//  Created by Matteo Casu on 06/02/25.
//

import UIKit
import EssentialProductsiOS

extension ProductItemCell {
    
    func simulateRetryAction() {
        productImageRetryButton.simulateTap()
    }

    var isShowingLoadingIndicator: Bool {
        return productContainerImageView.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !productImageRetryButton.isHidden
    }
    
    var renderedImage: Data? {
        return productImageView.image?.pngData()
    }
    
    var productName: String? {
        productNameLabel.text
    }
    
    var productDescription: String? {
        productDescriptionLabel.text
    }
    
    var productPrice: String? {
        productPriceLabel.text
    }
}

