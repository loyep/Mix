//
//  WeiboTableViewCell.swift
//  Mix
//
//  Created by Maxwell on 2017/9/2.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
//import YYText

class WeiboTableViewCell: UITableViewCell {
    
    var profileImage: UIButton = {
        let proImage = UIButton(type: .custom)
        proImage.backgroundColor = UIColor.white
        proImage.layer.cornerRadius = 18
        proImage.layer.masksToBounds = true
        proImage.layer.borderColor = UIColor.lightGray.cgColor
        proImage.layer.borderWidth = 1 / UIScreen.main.scale
        return proImage
    }()
    
    var name: UILabel = {
        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 15)
        return name
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() -> () {
        contentView.addSubview(name)
        contentView.addSubview(profileImage)
        contentView.addSubview(textView)
        profileImage.frame = CGRect(x: 10, y: 10, width: 36, height: 36)
        name.frame = CGRect(x: profileImage.frame.maxX + 10, y: 10, width: UIScreen.main.bounds.size.width - 80, height: 18)
        textView.frame = CGRect(x: name.frame.origin.x, y: name.frame.maxY + 5, width: name.frame.size.width, height: 0)
    }
    
    func bindViewModel(_ model: WeiboStatus) -> () {
        name.text = model.user?.screen_name
        
        let text = NSMutableAttributedString(string: model.text).addLinks().replaceEmotion().replaceFullText()
        textView.attributedText = text
        
        let textSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        textView.frame.size.height = textSize.height
        
        let imageUrl = (model.user?.profile_image_url)!
        
        profileImage.mix_setImage(URL(string: imageUrl)!, placeHolder: nil, for: .normal)
    }
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
