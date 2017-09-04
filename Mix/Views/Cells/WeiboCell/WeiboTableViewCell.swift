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
        textView.font = UIFont.systemFont(ofSize: 18)
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
        let text = model.weiboAttr
        textView.attributedText = text
        textView.frame.size.height = model.textHeight
        let imageUrl = (model.user?.profile_image_url)!
        profileImage.mix_setImage(URL(string: imageUrl)!, placeHolder: nil, for: .normal)
    }
}
