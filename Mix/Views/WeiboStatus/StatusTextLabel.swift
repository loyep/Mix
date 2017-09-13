//
//  WeiboLabel.swift
//  Mix
//
//  Created by Maxwell on 13/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import YYText

class StatusTextLabel: YYLabel {
    
    override var text: String? {
        willSet {
            guard newValue != text else {
                return
            }
            
            if let text = newValue {
                self.textLayout = yyTextLayout(text)
            } else {
                self.textLayout = nil
            }
        }
    }
    
    override var textLayout: YYTextLayout? {
        willSet {
            if let textLayout = newValue {
                self.frame.size.height = textLayout.textBoundingSize.height
            } else {
                self.frame.size.height = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        ignoreCommonProperties = true
        displaysAsynchronously = true
        fadeOnAsynchronouslyDisplay = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func yyTextLayout(_ text: String) -> YYTextLayout {
        let textAttr = text.weibStatusAttributedString()
        let container = YYTextContainer(size: CGSize(width: frame.width, height: CGFloat(MAXFLOAT)), insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return YYTextLayout(container: container, text: textAttr)!
    }
}
