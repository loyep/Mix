//
//  StatusView.swift
//  Mix
//
//  Created by Maxwell on 2017/10/17.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit

class StatusView: UIView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: StatusTextLabel!
    @IBOutlet weak var retweenTextView: StatusTextLabel!
    @IBOutlet weak var photoView: StatusPhotoView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutIfNeeded()
        var newSize = size
        newSize.height = photoView.frame.maxY
        return newSize
    }
    
}
