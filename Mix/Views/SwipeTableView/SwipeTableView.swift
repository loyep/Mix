//
//  SwipeTableView.swift
//  Mix
//
//  Created by Maxwell on 20/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

public protocol SwipeTableViewDataSource: NSObjectProtocol {
    
    @available(iOS 8.0, *)
    func swipeTableView(_ swipeTableView: SwipeTableView, viewForItemAt index: Int, reusingView: UIScrollView) -> UIScrollView
    
    @available(iOS 8.0, *)
    func numberOfSections(in swipeTableView: SwipeTableView) -> Int
}

@objc public protocol SwipeTableViewDelegate: NSObjectProtocol {
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableViewDidScroll(_ swipeTableView: SwipeTableView)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableViewCurrentItemIndexDidChange(_ swipeTableView: SwipeTableView)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableViewWillBeginDragging(_ swipeTableView: SwipeTableView)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableViewDidEndDragging(_ swipeTableView: SwipeTableView, willDecelerate decelerate: Bool)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableViewDidEndScrollingAnimation(_ swipeTableView: SwipeTableView)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableView(_ swipeTableView: SwipeTableView, shouldSelect itemAtIndex: Int) -> Bool
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableView(_ swipeTableView: SwipeTableView, didSelect itemAtIndex: Int)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableView(_ swipeTableView: SwipeTableView, shouldPullToRefresh atIndex: Int) -> Bool
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableView(_ swipeTableView: SwipeTableView, heightForRefeshHeader atIndex: Int) -> CGFloat
}


open class SwipeTableView: UIView, UIScrollViewDelegate {
    
    public weak var delegate: SwipeTableViewDelegate?
    
    public weak var dataSource: SwipeTableViewDataSource?
    
    open fileprivate(set) var contentView: UICollectionView = UICollectionView(frame: .zero) {
        willSet {
            if contentView == newValue { return }
            contentView.collectionViewLayout = self.layout
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentView.showsHorizontalScrollIndicator = false
            contentView.isPagingEnabled = true
            contentView.scrollsToTop = false
            contentView.delegate = self
            contentView.dataSource = self
            contentView.registerClassOf(UICollectionViewCell.self)
            if #available(iOS 10.0, *) { contentView.isPrefetchingEnabled = false }
        }
    }
    
    lazy fileprivate var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.itemSize = self.bounds.size
        return layout
    }()
    
    open var swipeHeaderView: UIView? {
        willSet {
            if newValue != swipeHeaderView {
                swipeHeaderView?.removeFromSuperview()
                if let swipeHeaderView = newValue {
                    addSubview(swipeHeaderView)
                    swipeHeaderView.frame.origin.y += swipeHeaderTopInset
                    headerInset = swipeHeaderView.frame.height
                    if let swipeHeaderView = swipeHeaderView as? SwipeTableHeaderView { swipeHeaderView.delegate = (self as? SwipeTableHeaderViewDelegate) }
                }
                reloadData()
                layoutIfNeeded()
            }
        }
    }
    
    open var swipeHeaderBar: UIView?
    
    open var swipeHeaderTopInset = CGFloat(64)
    
    open var currentItemIndex: Int = 0
    
    open var alwaysBounceHorizontal: Bool = true {
        didSet {
            contentView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
    }
    
    open var shouldAdjustContentSize: Bool = false
    
    open var swipeHeaderBarScrollDisabled: Bool = false
    
    open var scrollEnabled: Bool = true
    
    fileprivate var headerInset = CGFloat(0)
    
    fileprivate var barInset = CGFloat(0)
    
    fileprivate var cunrrentItemIndexpath = IndexPath(item: 0, section: 0)
    
    fileprivate var currentItemView: UIScrollView? {
        willSet {
            currentItemView?.scrollsToTop = false
            newValue?.scrollsToTop = true
        }
    }
    
    fileprivate var shouldVisibleItemIndex: Int = 0
    
    fileprivate var shouldVisibleItemView: UIScrollView?
    
    fileprivate var contentOffsetQuene: [Int: CGPoint] = [:]
    
    fileprivate var contentSizeQuene: [Int: CGSize] = [:]
    
    fileprivate var contentMinSizeQuene: [Int: CGSize] = [:]
    
    fileprivate var switchPageWithoutAnimation: Bool = true
    
    fileprivate var isAdjustingcontentSize: Bool = false
    
    fileprivate var contentOffsetKVODisabled: Bool = false
    
    fileprivate struct SwipeTableRuntimeKey {
//        UnsafeMutableRawPointer
        static let swipeTableViewItemContentOffsetContextKey = UnsafeRawPointer(bitPattern: "swipeTableViewItemContentOffsetContextKey".hashValue)
        //        static let swipeTableViewItemTopInsetKey = UnsafeRawPointer(bitPattern: "swipeTableViewItemTopInsetKey".hashValue)
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let autoAdjustInsetsView = UIScrollView()
        autoAdjustInsetsView.scrollsToTop = false
        addSubview(autoAdjustInsetsView)
        addSubview(contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func reloadData() {
        
    }
    
    open func scrollToItemAtIndex(_ atIndex: Int, animated: Bool) {
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
        self.layout.itemSize = self.bounds.size
        //        self.swipeHeaderBarScrollDisabled &= nil == _swipeHeaderView;
        self.swipeHeaderBar?.frame.origin.y = swipeHeaderView?.frame.maxY ?? 0
        if swipeHeaderBarScrollDisabled {
            swipeHeaderView?.frame.origin.y = swipeHeaderTopInset
        }
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        reloadData()
    }
    
}

extension SwipeTableView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        guard var subView = cell.scrollView else {
            return cell
        }
        if let newSubView = dataSource?.swipeTableView(self, viewForItemAt: indexPath.item, reusingView: subView) {
            newSubView.scrollsToTop = false
            let topInset = headerInset + barInset + swipeHeaderTopInset
            var contentInset = newSubView.contentInset
            if newSubView.swipeTableViewItemTopInset {
                contentInset.top += topInset - contentInset.top
                newSubView.contentInset = contentInset
                newSubView.scrollIndicatorInsets = contentInset
            } else {
                contentInset.top += topInset
                newSubView.contentInset = contentInset
                newSubView.scrollIndicatorInsets = contentInset
                newSubView.contentOffset = CGPoint(x: 0, y: -topInset)
                newSubView.swipeTableViewItemTopInset = true
            }
            
            if newSubView != subView {
                subView.removeFromSuperview()
                cell.contentView.addSubview(newSubView)
                subView = newSubView
            }
        }
        
        shouldVisibleItemView?.removeObserver(self, forKeyPath: "contentOffset")
        shouldVisibleItemView?.removeObserver(self, forKeyPath: "contentSize")
        shouldVisibleItemView?.removeObserver(self, forKeyPath: "panGestureRecognizer.state")
        shouldVisibleItemIndex = indexPath.item
        shouldVisibleItemView = subView
        shouldVisibleItemView?.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
        shouldVisibleItemView?.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        shouldVisibleItemView?.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: [.old, .new], context: nil)
        
        let lastItemView = currentItemView
        let lastIndex = currentItemIndex
        if switchPageWithoutAnimation {
            currentItemView?.removeObserver(self, forKeyPath: "contentOffset")
            currentItemView?.removeObserver(self, forKeyPath: "contentSize")
            currentItemView?.removeObserver(self, forKeyPath: "panGestureRecognizer.state")
            subView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
            subView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
            subView.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: [.old, .new], context:nil)
            currentItemIndex = indexPath.item
            currentItemView = subView
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0, execute: {
                self.switchPageWithoutAnimation = !self.switchPageWithoutAnimation
            })
        }
        
        adjustItemViewContentOffset(subView, at: indexPath.item, from: lastItemView!, lastIndex: lastIndex)
        return cell;
    }
    
    func adjustItemViewContentOffset(_ itemView: UIScrollView, at index: Int, from lastItemView: UIScrollView, lastIndex: Int) {
        
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            
        } else if keyPath == "contentSize" {
            
        } else if keyPath == "panGestureRecognizer.state" {
            
        }
    }
    
}

extension SwipeTableView: UICollectionViewDelegate {
    
}

public extension UIScrollView {
    
    fileprivate struct SwipeTableRuntimeKey {
        static let swipeTableViewItemTopInsetKey = UnsafeRawPointer(bitPattern: "swipeTableViewItemTopInsetKey".hashValue)
    }
    
    public weak var swipeTableView: SwipeTableView? {
        return nil
    }
    
    var swipeTableViewItemTopInset: Bool {
        get {
            return (objc_getAssociatedObject(self, UIScrollView.SwipeTableRuntimeKey.swipeTableViewItemTopInsetKey!) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, UIScrollView.SwipeTableRuntimeKey.swipeTableViewItemTopInsetKey!, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

extension UICollectionViewCell {
    
    var scrollView: UIScrollView? {
        for (_, item) in contentView.subviews.enumerated() {
            if item.isKind(of: UIScrollView.self) { return item as? UIScrollView }
        }
        return nil
    }
    
}
