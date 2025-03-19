//
//  ErrorView.swift
//  EssentialProductsiOS
//
//  Created by Matteo Casu on 19/03/25.
//

import UIKit

public final class ErrorView: UICollectionReusableView {
    
    @IBOutlet private weak var label: UILabel!
     
    public var message: String? {
        get { label.text }
        set { label.text = newValue }
    }
}
