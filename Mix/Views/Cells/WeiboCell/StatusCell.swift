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
        textView.backgroundColor = .white
        
        textView.highlightTapAction = self.highlightTapAction
        textView.highlightLongPressAction = self.highlightLongPressAction
        return textView
    }()
    
    lazy var retweetedTextView: YYLabel = {
        let textView = YYLabel()
        textView.isUserInteractionEnabled = true
        textView.ignoreCommonProperties = true
        textView.displaysAsynchronously = true
        textView.fadeOnAsynchronouslyDisplay = false
        textView.backgroundColor = .gray
        
        textView.highlightTapAction = self.highlightTapAction
        textView.highlightLongPressAction = self.highlightLongPressAction
        return textView
    }()
    
    lazy var dateView: UILabel = {
        let dateView = UILabel()
        dateView.textColor = UIColor.gray
        dateView.font = UIFont.systemFont(ofSize: 12)
        return dateView
    }()
    
    weak var status: WeiboStatus? = nil
    
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
        contentView.addSubview(retweetedTextView)
        
        profileImage.frame = CGRect(x: 10, y: 10, width: 36, height: 36)
        name.frame = CGRect(x: profileImage.frame.maxX + 10, y: 10, width: UIScreen.main.bounds.width - 80, height: 18)
        dateView.frame = CGRect(x: name.frame.minX, y: profileImage.frame.maxY - 16, width: name.frame.width, height: 16)
        textView.frame.origin.y = profileImage.frame.maxY + 10
        textView.frame.size.width = UIScreen.main.bounds.width - 20
        retweetedTextView.frame.size.width = textView.frame.width
    }
    
    func bind(for viewModel: WeiboStatus) -> () {
        status = viewModel
        name.text = viewModel.user?.screen_name
        if let layout = viewModel.yyTextLayout, textView.textLayout != layout {
            textView.textLayout = layout
            textView.frame.size.height = layout.textBoundingSize.height
        }
        
        retweetedTextView.frame.origin.y = textView.frame.maxY
        if let retweeted = viewModel.retweeted_status?.yyTextLayout, retweetedTextView.textLayout != retweeted {
            retweetedTextView.textLayout = retweeted
            retweetedTextView.frame.size.height = retweeted.textBoundingSize.height
        } else {
            retweetedTextView.textLayout = nil
            retweetedTextView.frame.size.height = 0
        }
        
        let imageUrl = (viewModel.user?.profile_image_url)!
        profileImage.mix_setImage(URL(string: imageUrl)!, placeHolder: nil, for: .normal)
        
        dateView.text = "\(viewModel.createdDate ?? "") \(viewModel.sourceName)"
    }
    
    override var isHighlighted: Bool {
        willSet {
            UIView.animate(withDuration: 0.2) {
                if newValue {
                    let scaleLine = max(self.frame.width, self.frame.height)
                    let scale = (scaleLine - 6) / scaleLine
                    self.transform = CGAffineTransform(scaleX: scale, y: scale)
                } else {
                    self.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        if status?.yyTextLayout?.textBoundingSize.height + status?.retweeted_status?.yyTextLayout?.textBoundingSize.height + 46 {
//        }
        layoutAttributes.frame.size.height = ((status?.yyTextLayout?.textBoundingSize.height ?? 0) + (status?.retweeted_status?.yyTextLayout?.textBoundingSize.height ?? 0) + 56)
//        if retweetedTextView.isHidden {
//            layoutAttributes.frame.size.height = textView.frame.maxY + 500
//        } else {
//            layoutAttributes.frame.size.height = retweetedTextView.frame.maxY + 10
//        }
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




