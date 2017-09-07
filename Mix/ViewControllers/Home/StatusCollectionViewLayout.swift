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
        estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width - 20, height: 400)
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepare() {
        super.prepare()
        
    }
}
