//
//  MixTheme.swift
//  Mix
//
//  Created by Maxwell on 05/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

public struct Theme {
    
    static var font: UIFont = {
        return UIFont.regular
    }()
    
    static var linkColor: UIColor = {
        return UIColor.orange
    }()
    
    static var linkHighLightColor: UIColor = {
        return .lightGray
    }()
    
    static var lineSpacing: Float = {
        return 16.0
    }()
    
//    static var NSBackgroundColorAttributeName
    static var textBackgroundColor: UIColor = {
        return .lightGray
    }()
    
    static var paragraph: NSParagraphStyle = {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineSpacing = CGFloat(Theme.lineSpacing)
        return paragraph
    }()
}
