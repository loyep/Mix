//
//  WeiboAttributedString.swift
//  Mix
//
//  Created by Maxwell on 05/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import YYKit
import RealmSwift

extension NSRegularExpression {
    
    static let linksRegex: NSRegularExpression = try! NSRegularExpression(pattern: "([https]+://[a-zA-Z0-9./]*)", options: [])
    
    static let emojiRegex: NSRegularExpression = try! NSRegularExpression(pattern: "(#\\w+#)|(@\\w+)", options: [])
    
    static let topicRegex: NSRegularExpression = try! NSRegularExpression(pattern: "(#[^#]+#)|(@[\\u4e00-\\u9fa5a-zA-Z0-9_-]{2,30})", options: [])
    
    static let emotionRegex: NSRegularExpression = try! NSRegularExpression(pattern: "(\\[+[a-zA-Z0-9\\u2e80-\\u9fff]{0,20}+\\])", options: [])
    
}

extension String {
    
    func weibStatusAttributedString(_ tintColor: UIColor) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: self)
        attr.setColor(tintColor, range: attr.rangeOfAll())
        
        for (_, result) in NSRegularExpression.topicRegex.matches(in: attr.string, options: .withoutAnchoringBounds, range: attr.rangeOfAll()).enumerated() {
            let range = result.range
            guard range.location != NSNotFound, range.length > 0 else { continue }
            if (attr.attribute(NSAttributedStringKey(rawValue: YYTextBindingAttributeName), at: range.location, effectiveRange: nil) != nil) { continue }
            
            let binding = YYTextBinding(deleteConfirm: false)
            let highLight = YYTextHighlight(backgroundColor: Theme.linkHighLightColor)
            attr.addAttributes([NSAttributedStringKey(rawValue: YYTextBindingAttributeName): binding, NSAttributedStringKey(rawValue: YYTextHighlightAttributeName): highLight, NSAttributedStringKey.foregroundColor: Theme.linkColor], range: range)
        }
        
        if let realm = try? Realm(dbName: .public) {
            let attrString = attr.string
            let attStr = attrString as NSString
            let fontSize = CGSize(width: Theme.font.pointSize, height: Theme.font.pointSize)
            for (_, result) in NSRegularExpression.emotionRegex.matches(in: attrString, options: .withoutAnchoringBounds, range: attr.rangeOfAll()).enumerated().reversed() {
                let range = result.range
                guard range.location != NSNotFound, range.length > 0 else { continue }
                if (attr.attribute(NSAttributedStringKey(rawValue: YYTextBindingAttributeName), at: range.location, effectiveRange: nil) != nil) { continue }
                
                guard let url = realm.object(ofType: WeiboEmotion.self, forPrimaryKey: attStr.substring(with: range))?.icon, let URL = URL(string: url) else { continue }
                let image = UIImageView()
                image.bounds.size = fontSize
//                image.kf.setImage(with: URL, placeholder: nil, options: [.backgroundDecode, .cacheOriginalImage], progressBlock: nil, completionHandler: nil)
                let attach = NSMutableAttributedString.attachmentString(withContent: image, contentMode: .center, attachmentSize: CGSize(width: fontSize.width + 4, height: fontSize.height), alignTo: Theme.font, alignment: .center)
                attr.replaceCharacters(in: range, with: attach)
            }
        }
        return attr
    }
}

extension String {
    
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
