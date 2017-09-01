//
//  PlusTabBarItemContentView.swift
//  Mix
//
//  Created by Maxwell on 31/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class TabBarItemPlusContentView: TabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.backgroundColor = UIColor.white
        self.imageView.layer.borderColor = UIColor(white: 235 / 255.0, alpha: 1.0).cgColor
        self.imageView.layer.borderWidth = 2.0
        self.imageView.layer.cornerRadius = 23
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        self.superview?.bringSubview(toFront: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }
    
    public override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 2.0, height: 2.0)))
        view.layer.cornerRadius = 1.0
        view.layer.opacity = 0.5
        view.backgroundColor = UIColor(red: 10/255.0, green: 66/255.0, blue: 91/255.0, alpha: 1.0)
        self.addSubview(view)
        playMaskAnimation(animateView: view, target: self.imageView, completion: {
            [weak view] in
            view?.removeFromSuperview()
            completion?()
        })
    }
    
    public override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func deselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("small", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = self.imageView.transform.scaledBy(x: 0.8, y: 0.8)
        self.imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
    public override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        UIView.beginAnimations("big", context: nil)
        UIView.setAnimationDuration(0.2)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        UIView.commitAnimations()
        completion?()
    }
    
    private func playMaskAnimation(animateView view: UIView, target: UIView, completion: (() -> ())?) {
        view.center = CGPoint(x: target.frame.origin.x + target.frame.size.width / 2.0, y: target.frame.origin.y + target.frame.size.height / 2.0)
        
        //        let scale = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        //        scale?.fromValue = NSValue(cgSize: CGSize(width: 1.0, height: 1.0))
        //        scale?.toValue = NSValue(cgSize: CGSize(width: 36.0, height: 36.0))
        //        scale?.beginTime = CACurrentMediaTime()
        //        scale?.duration = 0.3
        //        scale?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        //        scale?.removedOnCompletion = true
        //
        //        let alpha = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        //        alpha?.fromValue = 0.6
        //        alpha?.toValue = 0.6
        //        alpha?.beginTime = CACurrentMediaTime()
        //        alpha?.duration = 0.25
        //        alpha?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        //        alpha?.removedOnCompletion = true
        //
        //        view.layer.pop_add(scale, forKey: "scale")
        //        view.layer.pop_add(alpha, forKey: "alpha")
        
        //        scale?.completionBlock = ({ animation, finished in
        completion?()
        //        })
    }
    
}
