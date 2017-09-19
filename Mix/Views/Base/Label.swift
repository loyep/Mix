//
//  Label.swift
//  Mix
//
//  Created by Maxwell on 19/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

@IBDesignable class Label: UILabel {
    
    @IBInspectable override var text: String? {
        didSet {
            if text != nil, NSLocalizedString(text!, comment: "") != text! {
                text = NSLocalizedString(text!, comment: "")
            }
        }
    }
}
