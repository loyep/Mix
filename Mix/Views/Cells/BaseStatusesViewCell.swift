//
//  BaseStatusesViewCell.swift
//  Mix
//
//  Created by Maxwell on 20/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class BaseStatusesViewCell: UICollectionViewCell {
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = size
        return layoutAttributes
    }
    
}
