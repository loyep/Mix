//
//  StatusPhotoView.swift
//  Mix
//
//  Created by Maxwell on 11/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class StatusPhotoView: UIView {
    
    fileprivate var imageViews: [UIImageView] = []
    
    public var photos: [String] = [] {
        didSet {
            if imageViews.isEmpty {
                setupUI()
            }
            
            if photos.count <= imageViews.count {
                imageViews[photos.count..<imageViews.count].forEach { $0.isHidden = true }
            }
            
            guard photos.count > 0 else {
                frame.size.height = 0
                return
            }
            
            let itemW = itemWidthForPhotosCount(photos.count)
            var itemH = CGFloat(0)
            if photos.count == 1 {
                itemH = itemW
            } else {
                itemH = itemW
            }
            
            let perRowItemCount = itemRowsForPhotosCount(photos.count)
            let margin: CGFloat = 5.0
            
            for (i, item) in photos.enumerated() {
                let colunIndex = i % perRowItemCount
                let rowIndex = i / perRowItemCount
                let imageView = imageViews[i]
                imageView.isHidden = false
                imageView.kf.setImage(with: URL(string: item))
                imageView.frame = CGRect(x: CGFloat(colunIndex) * (itemW + margin), y: CGFloat(rowIndex) * (itemH + margin), width: itemW, height: itemH)
            }
            
//            let w = CGFloat(perRowItemCount) * itemW + (CGFloat(perRowItemCount) - 1) * margin
            let columnCount = ceil(Double(photos.count) / Double(perRowItemCount))
            let h = CGFloat(columnCount) * itemH + CGFloat(columnCount - 1) * margin
            
//            frame.size.width = w
            frame.size.height = h
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() -> () {
        for i in 0..<9 {
            let image = UIImageView()
            image.tag = i
            addSubview(image)
            image.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(StatusPhotoView.imageTapGesture))
            image.addGestureRecognizer(tap)
            imageViews.append(image)
        }
    }

    func itemWidthForPhotosCount(_ phototsCount: Int) -> CGFloat {
        if phototsCount == 1 {
            return 120
        } else {
            return (frame.width - 5 * 2) / 3
        }
    }
    
    func itemRowsForPhotosCount(_ photosCount: Int) -> Int {
        if photosCount < 3 {
            return photosCount
        } else {
            return 3
        }
    }
    
    @objc func imageTapGesture() {
        
    }
    
}