//
//  StatusCollectionLayout.swift
//  Mix
//
//  Created by Maxwell on 06/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

open class StatusCollectionViewLayout: UICollectionViewFlowLayout {
    
    public override init() {
        super.init()
        estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width - StatusCell.CellInset.left - StatusCell.CellInset.right, height: 400)
        minimumLineSpacing = StatusCell.CellInset.top
        sectionInset = StatusCell.CellInset
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
}
