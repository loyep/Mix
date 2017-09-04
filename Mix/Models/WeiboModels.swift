//
//  WeiboModels.swift
//  Mix
//
//  Created by Maxwell on 01/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift

class WeiboHomeLine: Object {
    
    @objc override static func primaryKey() -> String? {
        return "since_id"
    }
    
    dynamic var since_id = 0
    dynamic var max_id = 0
    dynamic var total_number = 0
    
    let statuses = List<WeiboStatus>()
    
}

class WeiboStatus: Object {
    
    @objc override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc override static func ignoredProperties() -> [String] {
        return ["weiboAttr", "rowHeight", "textHeight"]
    }
    
    dynamic var id = 0
    
    /// 微博创建时间
    dynamic var created_at: String?
    
    /// 微博信息内容
    dynamic var text: String = ""
    
    dynamic var source_type = 0
    
    /// 微博来源
    dynamic var source: String = ""
    
    /// 是否被截断，true：是，false：否
    dynamic var truncated = false
    
    /// 缩略图片地址，没有时不返回此字段
    dynamic var thumbnail_pic: String?
    
    /// 中等尺寸图片地址，没有时不返回此字段
    dynamic var bmiddle_pic: String?
    
    /// 原始图片地址，没有时不返回此字段
    dynamic var original_pic: String?
    
    /// （暂未支持）回复ID
    dynamic var in_reply_to_status_id: String?
    
    /// （暂未支持）回复人UID
    dynamic var in_reply_to_user_id: String?
    
    /// （暂未支持）回复人昵称
    dynamic var in_reply_to_screen_name: String?
    
    /// 微博作者的用户信息字段
    dynamic var user: WeiboUser?
    
    /// 转发数
    dynamic var reposts_count = 0
    
    /// 评论数
    dynamic var comments_count = 0
    
    /// 表态数
    dynamic var attitudes_count = 0
    
    /// 长文本
    dynamic var isLongText = false
    
    /// 是否已收藏，true：是，false：否
    dynamic var favorited = false
    
    /// 转发微博
    dynamic var retweeted_status: WeiboRetweetedStatus?
    
    lazy var weiboAttr: NSAttributedString = {
        return NSMutableAttributedString(string: self.text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]).addLinks().replaceEmotion().replaceFullText()
    }()
    
    var rowHeight: CGFloat {
        return textHeight + 56.0
    }
    
    lazy var textHeight: CGFloat = {
        return self.weiboAttr.boundingRect(with: CGSize(width: 295, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil).height
    }()
}

class WeiboRetweetedStatus: WeiboStatus {
    
}


class WeiboUser: Object {
    
    @objc override static func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var id = 0
    dynamic var cover_image_phone: String?
    dynamic var name: String?
    dynamic var screen_name: String?
    dynamic var profile_image_url: String?
    
}

extension Regex {
    
    static var fullTextRegex: Regex = {
        return Regex("(\\u5168\\u6587)： ([a-zA-z]+://[^\\s]*)")
    }()
    
    static var fullTexts: [[String: String]] = {
        guard let url = Bundle.main.path(forResource:"emoticons", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: url)),
            let json = try? JSONSerialization.jsonObject(with:data, options:JSONSerialization.ReadingOptions.mutableContainers) as! [[String: String]] else {
                return []
        }
        
        return json
    }()
    
    static var emotions: [[String: String]] = {
        guard let url = Bundle.main.path(forResource:"emoticons", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: url)),
            let json = try? JSONSerialization.jsonObject(with:data, options:JSONSerialization.ReadingOptions.mutableContainers) as! [[String: String]] else {
                return []
        }
        
        return json
    }()
    
    static var emotionRegex: Regex = {
        return Regex("(\\[+[\\u2e80-\\u9fff]{1,2}+\\])")
    }()
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
        for (_, result) in Regex("(#\\w+#)|(@\\w+)").allMatches(in: attr.string).map( { (range: $0.matchResult.range, string: $0.matchedString) } ).enumerated().reversed() {
            attr.addAttribute(NSLinkAttributeName, value: result.string.escape(result.string), range: result.range)
        }
        return attr
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

extension NSMutableAttributedString {
    
    override func replaceFullText() -> NSMutableAttributedString {
        for (_, fullText) in Regex.fullTextRegex.allMatches(in: self.string).map( { (range: $0.matchResult.range, string: $0.matchedString, strings: $0.captures ) } ).enumerated().reversed() {
            self.replaceCharacters(in: fullText.range, with: NSAttributedString(string: fullText.strings[0]!, attributes: [NSLinkAttributeName: fullText.strings[1]!]))
        }
        return self
    }
    
    override func addLinks() -> NSMutableAttributedString {
        for (_, result) in Regex("(#\\w+#)|(@\\w+)").allMatches(in: self.string).map( { (range: $0.matchResult.range, string: $0.matchedString) } ).enumerated().reversed() {
            self.addAttribute(NSLinkAttributeName, value: result.string.escape(result.string), range: result.range)
        }
        return self
    }
    
    override func replaceEmotion() -> NSMutableAttributedString {
        for (_, emotion) in self.string.emotionMatchs().enumerated().reversed() {
            if let emotionImage = Regex.emotions.filter({ $0["cht"] == emotion.string }).first?["img"] {
                let attach = NSTextAttachment()
                attach.image = UIImage(named: "\(emotionImage)")
                attach.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
                self.replaceCharacters(in: emotion.range, with: NSAttributedString(attachment: attach))
            }
        }
        return self
    }
    
}

extension WeiboTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("\(URL.absoluteString.removingPercentEncoding!)")
        return false
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(URL.absoluteString.removingPercentEncoding!)")
        return false
    }
    
}
