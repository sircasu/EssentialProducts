//
//  ProductListItemCell.swift
//  Prototype
//
//  Created by Matteo Casu on 04/02/25.
//

import UIKit

class ProductListItemCell: UICollectionViewCell {
    @IBOutlet weak var productContainerImageView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        productImageView.alpha = 0
        productContainerImageView.startShimmering()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        productImageView.alpha = 0
        productContainerImageView.startShimmering()
    }

    public func fadeIn(_ image: String) {
        
        productImageView.image = UIImage(named: image)

        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.productImageView.alpha = 1
            },
            completion: { completed in
                if completed {
                    self.productContainerImageView.stopShimmering()
                }
            }
        )
    }
    
    public func configure(with viewModel: ProductListViewModel) {
        productNameLabel.text = viewModel.productName
        productDescriptionLabel.text = viewModel.productDescription
        productPriceLabel.text = viewModel.productPrice
    }
}


private extension UIView {
    
    private var shimmerAnimationKey: String { "shimmer" }
    
    func startShimmering() {
        
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width: CGFloat = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }

    func stopShimmering() {
        layer.mask = nil
    }
}
