//
//  SwipeTableHeaderView.swift
//  Mix
//
//  Created by Maxwell on 20/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

@objc public protocol SwipeTableHeaderViewDelegate: NSObjectProtocol {
    
    func minHeaderViewFrameOrgin() -> CGPoint
    func maxHeaderViewFrameOrgin() -> CGPoint
    
    @objc optional func headerViewDidFrameChanged(_ headerView: SwipeTableHeaderView)
    
    @objc optional func headerView(_ headerView: SwipeTableHeaderView, didPan pan: UIPanGestureRecognizer)
    
    @objc optional func headerView(_ headerView: SwipeTableHeaderView, didPanGestureRecognizerStateChanged pan: UIPanGestureRecognizer)
    
}

open class SwipeTableHeaderView: UIView {
    
    public weak var delegate: SwipeTableHeaderViewDelegate?
    
    public fileprivate(set) var isTracking: Bool = false
    
    public fileprivate(set) var isDragging: Bool = false
    
    public fileprivate(set) var isDecelerating: Bool = false
    
    lazy var animator: UIDynamicAnimator? = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self;
        return animator
    }()
    
    var decelerationBehavior: UIDynamicItemBehavior?
    
    var springBehavior: UIAttachmentBehavior?
    
    fileprivate var dynamicItem: STDynamicItem = STDynamicItem()
    
    var newFrame: CGRect {
        set(newValue) {
            frame = newValue
            let minFrameOrgin = self.minFrameOrgin();
            let maxFrameOrgin = self.maxFrameOrgin();

            let outsideFrameMinimum = frame.origin.y < minFrameOrgin.y;
            let outsideFrameMaximum = frame.origin.y > maxFrameOrgin.y;

            if (outsideFrameMinimum || outsideFrameMaximum),
                decelerationBehavior != nil, springBehavior == nil {

                var target = frame.origin;
                if (outsideFrameMinimum) {
                    target.x = fmax(target.x, minFrameOrgin.x);
                    target.y = fmax(target.y, minFrameOrgin.y);
                } else if (outsideFrameMaximum) {
                    target.x = fmin(target.x, maxFrameOrgin.x);
                    target.y = fmin(target.y, maxFrameOrgin.y);
                }

                springBehavior = UIAttachmentBehavior(item: dynamicItem, attachedToAnchor: target)
                // Has to be equal to zero, because otherwise the frame wouldn't exactly match the target's position.
                springBehavior!.length = 0;
                // These two values were chosen by trial and error.
                springBehavior!.damping = 1;
                springBehavior!.frequency = 2;

                animator?.addBehavior(springBehavior!)
            }
            delegate?.headerViewDidFrameChanged?(self)
        }
        get {
            return frame
        }
    }
    
    public lazy fileprivate(set) var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeTableHeaderView.handlePanGesture(_:)))
        panGestureRecognizer.addObserver(self, forKeyPath: "state", options: [.old, .new], context: nil)
        return panGestureRecognizer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(panGestureRecognizer)
    }
    
    deinit {
        panGestureRecognizer.removeObserver(self, forKeyPath: "state")
    }
    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            endDecelerating()
            isTracking = true
        case .changed:
            isTracking = true
            isDragging = true
            var frame = self.frame
            let translation = pan.translation(in: superview)
            let newFrameOrginY = frame.origin.y + translation.y
            let minFrameOrgin = self.minFrameOrgin()
            let maxFrameOrgin = self.maxFrameOrgin()
            
            let minFrameOrginY = minFrameOrgin.y
            let maxFrameOrginY = maxFrameOrgin.y;
            
            let constrainedOrignY = fmax(minFrameOrginY, fmin(newFrameOrginY, maxFrameOrginY))
            let rubberBandedRate  = rubberBandRate(newFrameOrginY - constrainedOrignY)
            
            frame.origin.y += translation.y * rubberBandedRate
            newFrame = frame
            
            pan.setTranslation(CGPoint(x: translation.x, y: 0), in: superview)
        case .ended:
            isTracking = false
            isDragging = false
            var velocity = pan.velocity(in: self)
            velocity.x = 0
            dynamicItem.center = frame.origin
            decelerationBehavior = UIDynamicItemBehavior(items: [dynamicItem])
            decelerationBehavior!.addLinearVelocity(velocity, for: dynamicItem)
            decelerationBehavior!.resistance = 2
            decelerationBehavior!.action = {
                self.frame.origin.y = self.dynamicItem.center.y
            }
            animator?.addBehavior(decelerationBehavior!)
        default:
            isTracking = false
            isDragging = false
        }
        delegate?.headerView?(self, didPan: pan)
    }
    
    func rubberBandRate(_ offset: CGFloat) -> CGFloat {
        let constant = 0.15
        let dimension = 10.0
        let startRate = 0.85
        // 计算拖动视图translation的增量比率，起始值为startRate（此时offset为0）；随着frame超出的距离offset的增大，增量比率减小
        let result = dimension * startRate / (dimension + constant * fabs(Double(offset)))
        return CGFloat(result);
    }
    
    func minFrameOrgin() -> CGPoint {
        return delegate?.minHeaderViewFrameOrgin() ?? .zero
    }
    
    func maxFrameOrgin() -> CGPoint {
        return delegate?.maxHeaderViewFrameOrgin() ?? .zero
    }
    
    func endDecelerating() {
        animator?.removeAllBehaviors()
        decelerationBehavior = nil
        springBehavior = nil
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        endDecelerating()
        if bounds.contains(point), isDecelerating {
            return self
        }
        return view
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "state" {
            delegate?.headerView?(self, didPanGestureRecognizerStateChanged: panGestureRecognizer)
        }
    }
}

extension SwipeTableHeaderView: UIDynamicAnimatorDelegate {
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        isDecelerating = false
    }
    
    public func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        isDecelerating = true
    }
}

fileprivate class STDynamicItem: NSObject, UIDynamicItem {
    var center: CGPoint = .zero
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    var transform: CGAffineTransform = .identity
    
    override init() {
        super.init()
    }
    
}

