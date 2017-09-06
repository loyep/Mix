//
//  WeiboTableViewCell.swift
//  Mix
//
//  Created by Maxwell on 2017/9/2.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
import YYText

class StatusCell: UICollectionViewCell {
    
    var profileImage: UIButton = {
        let proImage = UIButton(type: .custom)
        proImage.backgroundColor = .white
        proImage.layer.cornerRadius = 18
        proImage.frame.size = CGSize(width: 36, height: 36)
        proImage.layer.borderColor = UIColor.lightGray.cgColor
        proImage.layer.shouldRasterize = true
        proImage.layer.masksToBounds = true
        return proImage
    }()
    
    var name: UILabel = {
        let name = UILabel()
        return name
    }()
    
    lazy var textView: YYLabel = {
        let textView = YYLabel()
        textView.isUserInteractionEnabled = true
        textView.ignoreCommonProperties = true
        textView.displaysAsynchronously = true
        textView.fadeOnAsynchronouslyDisplay = false
        textView.backgroundColor = .gray
        
        textView.highlightTapAction = self.highlightTapAction
        textView.highlightLongPressAction = self.highlightLongPressAction
        textView.textTapAction = self.textTapAction
        textView.textLongPressAction = self.textLongPressAction
        return textView
    }()
    
    lazy var dateView: YYLabel = {
        let dateView = YYLabel()
        dateView.textColor = UIColor.gray
        dateView.font = UIFont.systemFont(ofSize: 12)
        return dateView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() -> () {
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = contentView.layer.cornerRadius
        self.layer.shadowOpacity = 0.2
        
        contentView.addSubview(name)
        contentView.addSubview(dateView)
        contentView.addSubview(profileImage)
        contentView.addSubview(textView)
        
        profileImage.frame = CGRect(x: 10, y: 10, width: 36, height: 36)
        name.frame = CGRect(x: profileImage.frame.maxX + 10, y: 10, width: UIScreen.main.bounds.width - 80, height: 18)
        dateView.frame = CGRect(x: name.frame.minX, y: profileImage.frame.maxY - 18, width: name.frame.width, height: 18)
        textView.frame.origin.y = profileImage.frame.maxY + 10
        textView.frame.size.width = UIScreen.main.bounds.width - 20
    }
    
    func bindViewModel(_ model: WeiboStatus) -> () {
        name.text = model.user?.screen_name
        if let layout = model.yyTextLayout, textView.textLayout != layout {
            textView.textLayout = layout
            textView.frame.size.height = layout.textBoundingSize.height
        }
        let imageUrl = (model.user?.profile_image_url)!
        profileImage.mix_setImage(URL(string: imageUrl)!, placeHolder: nil, for: .normal)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let createdDate = model.created_at,
            let date = dateFormatter.date(from: createdDate) {
            let hour = Int(Date().timeIntervalSince(date) / 3600)
            switch hour {
            case 0:
                dateView.text = "刚刚"
            case 1..<24:
                dateView.text = "\(hour) 小时前"
            case 24..<48:
                dateFormatter.dateFormat = "昨天 HH:mm"
                dateView.text = "\(dateFormatter.string(from: date))"
            default:
                dateFormatter.dateFormat = "MM-dd HH:mm"
                dateView.text = "\(dateFormatter.string(from: date))"
            }
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size.height = textView.frame.maxY + 10
        return layoutAttributes
    }
    
}

extension StatusCell {
    
    ///=============================================================================
    /// @name Interacting with Text Data
    ///=============================================================================
    
    /// When user tap the label, this action will be called (similar to tap gesture).
    func textTapAction(containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) -> Void {
        
    }
    
    /// When user long press the label, this action will be called (similar to long press gesture).
    func textLongPressAction(containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) -> Void {
        
    }
    
    /// When user tap the highlight range of text, this action will be called.
    func highlightTapAction(containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) -> Void {
        let highLight = (text.attributes(at: NSMaxRange(range) - 1, effectiveRange: nil)["YYTextHighlight"] as! YYTextHighlight)
        print("\(highLight.userInfo?[NSLinkAttributeName]! ?? "")")
    }
    
    /// When user long press the highlight range of text, this action will be called.
    func highlightLongPressAction(containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) -> Void {
        let highLight = (text.attributes(at: NSMaxRange(range) - 1, effectiveRange: nil)["YYTextHighlight"] as! YYTextHighlight)
        print("\(highLight.userInfo?[NSLinkAttributeName]! ?? "")")
    }
}




