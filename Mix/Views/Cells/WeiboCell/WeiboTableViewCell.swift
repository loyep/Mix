//
//  WeiboTableViewCell.swift
//  Mix
//
//  Created by Maxwell on 2017/9/2.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift

class WeiboTableViewCell: UITableViewCell {
    
    var profileImage: UIButton = {
        let proImage = UIButton(type: .custom)
        proImage.backgroundColor = UIColor.red
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
        textView.dataDetectorTypes = .all
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
//        name.attributedText = try! NSAttributedString(data: model.source.data(using: .unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        textView.text = model.text
        
        let textSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        textView.frame.size.height = textSize.height
        
        let imageUrl = (model.user?.profile_image_url)!
        guard  let realm = try? Realm() else {
            return
        }
        
        if let webData = realm.object(ofType: RealmWebImage.self, forPrimaryKey: imageUrl)?.webCacheData {
            profileImage.setImage(UIImage(data: webData as Data), for: .normal)
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let this = self,
                let url = URL(string: imageUrl),
                let imageData = try? Data(contentsOf: url) else {
                    return
            }
            
            DispatchQueue.main.async { [weak this] in
                guard let realm = try? Realm(), let this = this else {
                    return
                }
                
                try? realm.write {
                    realm.create(RealmWebImage.self, value: ["imageUrl": imageUrl, "webCacheData": imageData, "webCacheSize": imageData.count], update: true)
                }
                this.profileImage.setImage(UIImage(data: imageData), for: .normal)
            }
        }
    }
    
}

extension WeiboTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
    
}
