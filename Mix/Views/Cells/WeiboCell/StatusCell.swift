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
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        textView.frame = CGRect(x: name.frame.origin.x, y: profileImage.frame.maxY + 5, width: name.frame.size.width, height: 0)
        
        textView.highlightTapAction = { containerView, text, range, rect in
            let highLight = (text.attributes(at: NSMaxRange(range) - 1, effectiveRange: nil)["YYTextHighlight"] as! YYTextHighlight)
            print("\(highLight.userInfo?[NSLinkAttributeName]! ?? "")")
        }
    }
    
    static var emotions: [String: UIImage] = {
        guard let url = Bundle.main.path(forResource:"emoticons", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: url)),
            let json = try? JSONSerialization.jsonObject(with:data, options:JSONSerialization.ReadingOptions.mutableContainers) as! [[String: String]] else {
                return [:]
        }
        var maps: [String: UIImage] = [:]
        for (_, j) in json.enumerated() {
            maps[j["chs"]!] = UIImage(named: j["img"]!)
        }
        return maps
    }()
    
    func bindViewModel(_ model: WeiboStatus) -> () {
        name.text = model.user?.screen_name
        if let layout = model.yyTextLayout, textView.textLayout != layout {
            textView.textLayout = layout
            textView.frame.size = layout.textBoundingSize
        }
        let imageUrl = (model.user?.profile_image_url)!
        profileImage.mix_setImage(URL(string: imageUrl)!, placeHolder: nil, for: .normal)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size.height = textView.frame.maxY
        layoutAttributes.frame.size.width = UIScreen.main.bounds.size.width
        return layoutAttributes
    }
    
}





