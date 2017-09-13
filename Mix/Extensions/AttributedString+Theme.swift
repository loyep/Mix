//
//  WeiboAttributedString.swift
//  Mix
//
//  Created by Maxwell on 05/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import YYText

extension NSRegularExpression {
    
    static let linksRegex: NSRegularExpression = try! NSRegularExpression(pattern: "([https]+://[a-zA-Z0-9./]*)", options: [])
    
    static let emojiRegex: NSRegularExpression = try! NSRegularExpression(pattern: "(#\\w+#)|(@\\w+)", options: [])
    
    static let topicRegex: NSRegularExpression = try! NSRegularExpression(pattern: "(#[^#]+#)|(@[\\u4e00-\\u9fa5a-zA-Z0-9_-]{2,30})", options: [])
    
    static let fullTextRegex: NSRegularExpression = try! NSRegularExpression(pattern: "", options: [])
    
}

extension String {
    
    func weibStatusAttributedString() -> NSAttributedString {
        let attr = NSMutableAttributedString(string: self)
        
        for (_, result) in NSRegularExpression.topicRegex.matches(in: attr.string, options: .withoutAnchoringBounds, range: attr.yy_rangeOfAll()).enumerated() {
            let range = result.range
            guard range.location != NSNotFound, range.length > 0 else { continue }
            if (attr.attribute(YYTextBindingAttributeName, at: range.location, effectiveRange: nil) != nil) { continue }
            
            let binding = YYTextBinding(deleteConfirm: false)
            let highLight = YYTextHighlight(backgroundColor: Theme.linkHighLightColor)
            attr.addAttributes([YYTextBindingAttributeName: binding, YYTextHighlightAttributeName: highLight, NSForegroundColorAttributeName: Theme.linkColor], range: range)
        }
//
//        for (_, result) in NSRegularExpression.linksRegex.matches(in: attr.string, options: .withoutAnchoringBounds, range: attr.yy_rangeOfAll()).enumerated() {
//            let range = result.range
//            guard range.location != NSNotFound, range.length > 0 else { continue }
//            if (attr.attribute(YYTextBindingAttributeName, at: range.location, effectiveRange: nil) != nil) { continue }
//            
//            let binding = YYTextBinding(deleteConfirm: false)
//            let highLight = YYTextHighlight(backgroundColor: Theme.linkHighLightColor)
//            attr.addAttributes([YYTextBindingAttributeName: binding, YYTextHighlightAttributeName: highLight, NSForegroundColorAttributeName: Theme.linkColor], range: range)
//        }
        
        return attr
    }
    
}

extension NSMutableAttributedString {
    
    override func replaceFullText() -> NSMutableAttributedString {
        
        for (_, fullText) in Regex.fullTextRegex.allMatches(in: self.string).map( { (range: $0.matchResult.range, string: $0.matchedString, strings: $0.captures ) } ).enumerated().reversed() {
            let attr = NSMutableAttributedString(string: fullText.strings[0]!,
                                                 attributes: [NSFontAttributeName: Theme.font,
                                                              NSForegroundColorAttributeName: Theme.linkColor,
                                                              NSParagraphStyleAttributeName: Theme.paragraph])
            let highLight = YYTextHighlight(attributes: [NSForegroundColorAttributeName: Theme.linkHighLightColor,
                                                         NSBackgroundColorAttributeName: Theme.textBackgroundColor,
                                                         NSParagraphStyleAttributeName: Theme.paragraph])
            highLight.userInfo = [NSLinkAttributeName: fullText.strings[1]!]
            attr.yy_setTextHighlight(highLight, range: NSMakeRange(0, attr.length))
            self.replaceCharacters(in: fullText.range, with: attr)
        }
        
        for (_, result) in Regex.linkTextRegex.allMatches(in: self.string).map( { (range: $0.matchResult.range, string: $0.matchedString) } ).enumerated().reversed() {
            
            let border = YYTextBorder(lineStyle: .single, lineWidth: 0, stroke: UIColor.orange)
            border.cornerRadius = 100
            border.lineJoin = CGLineJoin.bevel
            border.fillColor = UIColor.orange
            border.insets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
            
            let highLight = YYTextHighlight(attributes: [
                YYTextBackgroundBorderAttributeName: border,
                NSParagraphStyleAttributeName: Theme.paragraph])
            highLight.userInfo = [NSLinkAttributeName: result.string]
            
            let attr = NSMutableAttributedString(string: "   查看链接   ", attributes: [NSForegroundColorAttributeName: UIColor.white,
                                                                                                  NSFontAttributeName: Theme.font,
                                                                                                  YYTextHighlightAttributeName: highLight,
                                                                                                  YYTextBackgroundBorderAttributeName: border,
                                                                                                  NSParagraphStyleAttributeName: Theme.paragraph])
            attr.yy_setTextBinding(YYTextBinding(deleteConfirm: false), range: attr.yy_rangeOfAll())
            
            self.replaceCharacters(in: result.range, with: attr)
        }
        
        self.yy_lineBreakMode = .byWordWrapping
        
        return self
    }
    
    override func addLinks() -> NSMutableAttributedString {
        for (_, result) in Regex("(#\\w+#)|(@\\w+)").allMatches(in: self.string).map( { (range: $0.matchResult.range, string: $0.matchedString) } ).enumerated().reversed() {
            self.addAttributes([NSForegroundColorAttributeName: Theme.linkColor,
                                NSParagraphStyleAttributeName: Theme.paragraph
                ], range: result.range)
            let highLight = YYTextHighlight(attributes: [NSForegroundColorAttributeName: Theme.linkHighLightColor,
                                                         NSBackgroundColorAttributeName: Theme.textBackgroundColor,
                                                         NSParagraphStyleAttributeName: Theme.paragraph])
            highLight.userInfo = [NSLinkAttributeName: result.string]
            self.yy_setTextHighlight(highLight, range: result.range)
        }
        return self
    }
    
    override func replaceEmotion() -> NSMutableAttributedString {
        //        for (_, emotion) in self.string.emotionMatchs().enumerated().reversed() {
        //            if let emotionImage = Regex.emotions.filter({ $0["cht"] == emotion.string }).first?["img"] {
        //                let attach = NSTextAttachment()
        //                attach.image = UIImage(named: "\(emotionImage)")
        //                attach.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
        //                self.replaceCharacters(in: emotion.range, with: NSAttributedString(attachment: attach))
        //            }
        //        }
        return self
    }
}

extension String {
    
    fileprivate func emotionMatchs() -> [(range: NSRange, string: String)] {
        return Regex.emotionRegex
            .allMatches(in: self)
            .map { (range: $0.matchResult.range, string: $0.matchedString) }
    }
    
    fileprivate func fullTextMatchs() -> [(range: NSRange, string: String, strings: [String?])] {
        return Regex.fullTextRegex
            .allMatches(in: self)
            .map { (range: $0.matchResult.range, string: $0.matchedString, strings: $0.captures ) }
    }
    
    fileprivate var unicode: String {
        var scalars = ""
        var bytesIterator = self.utf8.makeIterator()
        var utf8Decoder = UTF8()
        Decode: while true {
            switch utf8Decoder.decode(&bytesIterator) {
            case .scalarValue(let v):
                scalars.append(v.escaped(asASCII: true))
            case .emptyInput: break Decode
            case .error:
                print("Decoding error")
                break Decode
            }
        }
        return scalars
    }
    
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
}

extension NSAttributedString {
    
    func replaceFullText() -> NSAttributedString {
        let attr = NSMutableAttributedString(attributedString: self)
        for (_, fullText) in Regex.fullTextRegex.allMatches(in: attr.string).map( { (range: $0.matchResult.range, string: $0.matchedString, strings: $0.captures ) } ).enumerated().reversed() {
            attr.replaceCharacters(in: fullText.range, with: NSAttributedString(string: fullText.strings[0]!, attributes: [NSLinkAttributeName: fullText.strings[1]!]))
        }
        return attr
    }
    
    func addLinks() -> NSAttributedString {
        let attr = NSMutableAttributedString(attributedString: self)
        return attr.addLinks()
    }
    
    func replaceEmotion() -> NSAttributedString {
        let attr = NSMutableAttributedString(attributedString: self)
        for (_, emotion) in attr.string.emotionMatchs().enumerated().reversed() {
            if let emotionImage = Regex.emotions.filter({ $0["cht"] == emotion.string }).first?["img"] {
                let attach = NSTextAttachment()
                attach.image = UIImage(named: "\(emotionImage)")
                attach.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
                attr.replaceCharacters(in: emotion.range, with: NSAttributedString(attachment: attach))
            }
        }
        return attr
    }
}
