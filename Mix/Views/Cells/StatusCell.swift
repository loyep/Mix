//
//  WeiboTableViewCell.swift
//  Mix
//
//  Created by Maxwell on 13/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SwiftTheme
import YYKit

class StatusCell: UICollectionViewCell {
    
    var statusView: StatusView = StatusView.instantiateFromNib()
    
    static let CellInset = UIEdgeInsetsMake(8, 8, 8, 8)
    
    weak var previewDelegate: UIViewControllerPreviewingDelegate? = nil
    
    var retweetedTextView = StatusTextLabel()
    
    var photosView = StatusPhotoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() -> () {
        contentView.addSubview(statusView)
        statusView.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(self)
        }
        
        contentView.backgroundColor = UIColor(white: 1, alpha: 1)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1 / UIScreen.main.scale, height: 1)
        self.layer.shadowRadius = contentView.layer.cornerRadius
        self.layer.shadowOpacity = 0.2
        
//        contentView.addSubview(name)
//        contentView.addSubview(dateView)
//        contentView.addSubview(profileImage)
//        contentView.addSubview(textView)
//        contentView.addSubview(retweetedTextView)
//        contentView.addSubview(photosView)
        
//        textView.highlightTapAction = self.highlightTapAction
//        textView.highlightLongPressAction = self.highlightLongPressAction
//
//        retweetedTextView.highlightTapAction = self.highlightTapAction
//        retweetedTextView.highlightLongPressAction = self.highlightLongPressAction
//
//        profileImage.frame = CGRect(x: 10, y: 10, width: 36, height: 36)
//        name.frame = CGRect(x: profileImage.frame.maxX + 10, y: 10, width: UIScreen.width - 80, height: 18)
//        dateView.frame = CGRect(x: name.frame.minX, y: profileImage.frame.maxY - 16, width: name.frame.width, height: 16)
//        textView.frame.origin.y = profileImage.frame.maxY + 10
//        textView.frame.size.width = UIScreen.width - StatusCell.CellInset.left - StatusCell.CellInset.right
//        retweetedTextView.frame.size.width = textView.frame.width
//        photosView.frame.size.width = textView.frame.width - StatusCell.CellInset.left - StatusCell.CellInset.right
//        photosView.frame.origin.x = StatusCell.CellInset.left
//
//        profileImage.layer.borderWidth = 1 / UIScreen.main.scale
//        profileImage.layer.cornerRadius = profileImage.width / 2
//        profileImage.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func bind(for viewModel: WeiboStatus, delegate: UIViewControllerPreviewingDelegate? = nil) -> () {
        previewDelegate = delegate
        statusView.nameLabel.text = viewModel.user?.screen_name
        
        if let profileImageUrl = URL(string: viewModel.user.profile_image_url ?? "") {
            statusView.profileImage.layer.setImageWith(profileImageUrl, placeholder: nil, options: .avoidSetImage, completion: { [weak statusView] (image, url, from, stage, error) in
                guard let profileImage = statusView?.profileImage else { return }
                profileImage.image = image?.byRoundCornerRadius(profileImage.width / 2)
            })
        }
        statusView.textView.text = viewModel.text
        if let picUrls = viewModel.retweetedStatus?.picUrls {
            statusView.photoView.photos = picUrls
        } else {
            statusView.photoView.photos = viewModel.picUrls
        }
        statusView.retweenTextView.text = viewModel.retweetedStatus?.text
        statusView.dateLabel.text = "\(createdDate(viewModel.createdAt as Date) ?? "") \(viewModel.source)"
        statusView.setNeedsLayout()
    }
    
    func createdDate(_ createdAt: Date) -> String? {
        let createdAt = createdAt
        if createdAt.isToday {
            let minute = Int(Date().timeIntervalSince(createdAt) / 60)
            if minute / 60 >= 1 {
                return "\(minute / 60)小时前"
            } else if minute >= 1 {
                return "\(minute)分钟前"
            } else {
                return "刚刚"
            }
        } else if createdAt.isYesterday {
            return createdAt.string(from: "昨天 HH:mm")
        } else if createdAt.isThisYear {
            return createdAt.string(from: "MM-dd HH:mm")
        } else {
            return createdAt.string(from: "yyyy-MM-dd HH:mm")
        }
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
        layoutAttributes.frame.size = statusView.sizeThatFits(CGSize(width: layoutAttributes.frame.width, height: CGFloat(MAXFLOAT)))
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
        //        let highLight = (text.attributes(at: NSMaxRange(range) - 1, effectiveRange: nil)["YYTextHighlight"] as! YYTextHighlight)
        //        print("\(highLight.userInfo?[NSAttributedStringKey.link]! ?? "")")
    }
    
    /// When user long press the highlight range of text, this action will be called.
    func highlightLongPressAction(containerView: UIView, text: NSAttributedString, range: NSRange, rect: CGRect) -> Void {
        //        let highLight = (text.attributes(at: NSMaxRange(range) - 1, effectiveRange: nil)["YYTextHighlight"] as! YYTextHighlight)
        //        print("\(highLight.userInfo?[NSAttributedStringKey.link]! ?? "")")
    }
}
