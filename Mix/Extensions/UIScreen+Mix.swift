//
//  UIScreen+Mix.swift
//  Mix
//
//  Created by Maxwell on 14/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

extension UIScreen {
    
    static var width: CGFloat {
        return min(main.bounds.size.width, main.bounds.size.height)
    }
    
    static var height: CGFloat {
        return max(main.bounds.size.width, main.bounds.size.height)
    }
    
}
