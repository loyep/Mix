//
//  StatusPhotoView.swift
//  Mix
//
//  Created by Maxwell on 11/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import YYKit

fileprivate class StatusPhotoControl: UIView {
    var image: UIImage? {
        didSet {
            layer.contents = image?.cgImage
        }
    }
    var point: CGPoint = .zero
    var timer: Timer?
    var longPressDetected: Bool = false
    var tapTouch: ((StatusPhotoControl, YYGestureRecognizerState, Set<UITouch>, UIEvent?) -> Void)?
    var longPress: ((StatusPhotoControl, CGPoint) -> Void)?
    
    deinit {
        endTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(StatusPhotoControl.timerFire), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    @objc func timerFire() {
        touchesCancelled(Set(), with: nil)
        longPressDetected = true
        longPress?(self, point)
        endTimer()
    }
    
    func endTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressDetected = false
        tapTouch?(self, .began, touches, event)
        if longPress != nil {
            point = touches.first?.location(in: self) ?? .zero
            startTimer()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if longPressDetected { return }
        tapTouch?(self, .moved, touches, event)
        endTimer()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if longPressDetected { return }
        tapTouch?(self, .ended, touches, event)
        endTimer()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if longPressDetected { return }
        tapTouch?(self, .cancelled, touches, event)
        endTimer()
    }
}

class StatusPhotoView: UIView {
    
    fileprivate var imageViews: [StatusPhotoControl] = []
    
    public var photos: [String] = [] {
        didSet {
            if imageViews.isEmpty {
                setupUI()
            }
            updatePhotos()
        }
    }
    
    fileprivate var photosSize = CGSize.zero
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return photosSize
    }
    
    override var intrinsicContentSize: CGSize {
        return photosSize
    }
    
    func updatePhotos() {
        
        var photosSize = CGSize(width: frame.width, height: 0)
        
        if photos.count <= imageViews.count {
            imageViews[photos.count..<imageViews.count].forEach { $0.isHidden = true }
        }
        
        if photos.count > 0 {
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
                imageView.layer.setImageWith(URL(string: item), placeholder: nil, options: .avoidSetImage, completion: { [weak imageView] (image, url, from, stage, error) in
                    guard let imageView = imageView else { return }
                    if image != nil, stage == .finished {
                        let imageSize = image!.size
                        let scale = (imageSize.height / imageSize.width) / (imageView.height / imageView.width)
                        if scale < 0.99 || scale.isNaN {
                            imageView.contentMode = .scaleAspectFill
                            imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                        } else {
                            imageView.contentMode = .scaleToFill
                            imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: imageSize.width / imageSize.height)
                        }
                        
                        imageView.image = image
                    }
                })
                imageView.frame = CGRect(x: CGFloat(colunIndex) * (itemW + margin), y: CGFloat(rowIndex) * (itemH + margin), width: itemW, height: itemH)
            }
            
            let columnCount = ceil(Double(photos.count) / Double(perRowItemCount))
            photosSize.height = CGFloat(columnCount) * itemH + CGFloat(columnCount - 1) * margin
        }
        
        self.photosSize = photosSize
        invalidateIntrinsicContentSize()
        print("\(photosSize) \(frame.size)")
    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        frame.size = photosSize
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() -> () {
        backgroundColor = .white
        for i in 0..<9 {
            let image = StatusPhotoControl()
            image.size = CGSize(width: 100, height: 100)
            image.layer.masksToBounds = true
            image.isExclusiveTouch = true
            image.backgroundColor = .white
            image.contentMode = .redraw
            image.tag = i
            addSubview(image)
            
            let badge = UIImageView()
            badge.isUserInteractionEnabled = false
            badge.contentMode = .scaleAspectFit
            badge.size = CGSize(width: 28, height: 18)
            badge.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            badge.right = image.width
            badge.bottom = image.height
            badge.isHidden = true
            image.addSubview(badge)
            
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
    
    @objc func imageTapGesture(_ sender: UIGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        print("tag: \(imageView.tag), url: \(photos[imageView.tag])")
    }
    
}
