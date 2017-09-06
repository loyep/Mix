//
//  StatusCollectionLayout.swift
//  Mix
//
//  Created by Maxwell on 06/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

open class StatusCollectionViewLayout: UICollectionViewFlowLayout {
    
    open var insets: UIEdgeInsets = .zero
    
    public override init() {
        super.init()
        if #available(iOS 10.0, *) {
            estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        } else {
            estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 200)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepare() {
        super.prepare()
        
    }
}
