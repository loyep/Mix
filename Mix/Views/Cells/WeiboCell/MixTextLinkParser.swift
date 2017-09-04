//
//  MixTextLinkParser.swift
//  Mix
//
//  Created by Maxwell on 2017/9/4.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
import YYText

@objc protocol YYLabelLinkActionDelegate {
    @objc optional func handleMailAction(string: String)
    @objc optional func handleMobileAction(string: String)
}

class YYLabelLinkParser: NSObject, YYTextParser {
    
    var mailRegex: NSRegularExpression!
    var mobileRegex: NSRegularExpression!
    
    override init() {
        super.init()
        let emailPattern = "(#\\w+#)|(@\\w+)"
        let mobilePattern = "(\\u5168\\u6587)： ([a-zA-z]+://[^\\s]*)"
        
        mailRegex = try! NSRegularExpression(pattern: emailPattern, options: NSRegularExpression.Options.init(rawValue: 0))
        mobileRegex = try! NSRegularExpression(pattern: mobilePattern, options: NSRegularExpression.Options.init(rawValue: 0))
        
    }
    
    public func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool {
        if let text = text {
            var change = false
            debugPrint("Parsing text: %@", text.string)
            mailRegex.enumerateMatches(in: text.string,
                                       options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                       range: text.yy_rangeOfAll(),
                                       using: {
                                        
                                        [weak self]
                                        (result, flags, stop) in
                                        if let result = result {
                                            let range = result.range
                                            if range.location == NSNotFound || range.length < 1 {
                                                return
                                            }
                                            
                                            let highlight = YYTextHighlight(backgroundColor: nil)
                                            highlight.setColor(UIColor.blue)
                                            highlight.tapAction =  {
                                                
                                                [weak self]
                                                (view, string, range, frame) in
                                                
//                                                
//                                                if let delegate = self?.delegate {
//                                                    delegate.handleMailAction?(string: string.attributedSubstring(from: range).string)
//                                                }
                                            }
                                            
                                            text.yy_setColor(UIColor.blue, range: range)
                                            text.yy_setTextHighlight(highlight, range: range)
                                            change = true
                                            debugPrint("Found email: %@", text.string)
                                        }
            })
            
            mobileRegex.enumerateMatches(in: text.string,
                                         options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                         range: text.yy_rangeOfAll(),
                                         using: {
                                            
                                            [weak self]
                                            (result, flags, stop) in
                                            if let result = result {
                                                let range = result.range
                                                if range.location == NSNotFound || range.length < 1 {
                                                    return
                                                }
                                                
                                                let highlight = YYTextHighlight(backgroundColor: nil)
                                                highlight.setColor(UIColor.blue)
                                                highlight.tapAction =  {
                                                    
                                                    [weak self]
                                                    (view, string, range, frame) in
                                                    // make phone call
//                                                    if let delegate = self?.delegate {
//                                                        delegate.handleMobileAction?(string: string.attributedSubstring(from: range).string)
//                                                    }
                                                }
                                                
                                                text.yy_setColor(UIColor.blue, range: range)
                                                text.yy_setTextHighlight(highlight, range: range)
                                                change = true
                                                
                                                debugPrint("Found mobile: %@", text.string)
                                            }
            })
            
            return change
        }
        return false
    }
}
