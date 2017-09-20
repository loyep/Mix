//
//  SwipeTableHeaderView.swift
//  Mix
//
//  Created by Maxwell on 20/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
//@class STHeaderView;
//@protocol STHeaderViewDelegate <NSObject>
//
//- (CGPoint)minHeaderViewFrameOrgin;
//- (CGPoint)maxHeaderViewFrameOrgin;
//
//@optional
//- (void)headerViewDidFrameChanged:(STHeaderView *)headerView;
//- (void)headerView:(STHeaderView *)headerView didPan:(UIPanGestureRecognizer *)pan;
//- (void)headerView:(STHeaderView *)headerView didPanGestureRecognizerStateChanged:(UIPanGestureRecognizer *)pan;
//
//@end
//
//
///**
// 采用 UIKitDynamics 实现自定的 swipeHeaderView
//
// 只有当`SwipeTableView`的 swipeHeaderView 是`STHeaderView`或其子类的实例,拖拽`SwipeTableView`的 swipeHeaderView才能 同时滚动`SwipeTableView`的 currentItemView.
// */
//NS_CLASS_AVAILABLE_IOS(7_0) @interface STHeaderView : UIView
//
//@property (nonatomic, readonly, strong) UIPanGestureRecognizer * panGestureRecognizer;
//@property (nonatomic, weak) id<STHeaderViewDelegate> delegate;
//@property (nonatomic, readonly, getter=isTracking)     BOOL tracking;
//@property (nonatomic, readonly, getter=isDragging)     BOOL dragging;
//@property (nonatomic, readonly, getter=isDecelerating) BOOL decelerating;
//
///**
// *  结束视图的 惯性减速 & 弹性回弹 等效果
// */
//- (void)endDecelerating;
//
//@end


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
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
