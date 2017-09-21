//
//  SwipeTableView.swift
//  Mix
//
//  Created by Maxwell on 20/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

@objc public protocol SwipeTableViewDataSource: NSObjectProtocol {
    
    @available(iOS 8.0, *)
    @objc func swipeTableView(_ swipeTableView: SwipeTableView, viewForItemAt index: Int, reusingView: UIScrollView) -> UIScrollView
    
    @available(iOS 8.0, *)
    @objc func numberOfSections(in swipeTableView: SwipeTableView) -> Int
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
    @objc optional func swipeTableViewWillBeginDecelerating(_ swipeTableView: SwipeTableView)
    
    @available(iOS 8.0, *)
    @objc optional func swipeTableViewDidEndDecelerating(_ swipeTableView: SwipeTableView)
    
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


@IBDesignable open class SwipeTableView: UIView, UIScrollViewDelegate {
    
    @IBOutlet public weak var delegate: SwipeTableViewDelegate?
    
    @IBOutlet public weak var dataSource: SwipeTableViewDataSource?
    
    public var contentView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        contentView.collectionViewLayout = layout
        contentView.delegate = self
        contentView.dataSource = self
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.showsHorizontalScrollIndicator = false
        contentView.isPagingEnabled = true
        contentView.scrollsToTop = false
        contentView.backgroundColor = .white
        contentView.registerClassOf(UICollectionViewCell.self)
        if #available(iOS 10.0, *) { contentView.isPrefetchingEnabled = false }
        
        let autoAdjustInsetsView = UIScrollView()
        autoAdjustInsetsView.scrollsToTop = false
        addSubview(autoAdjustInsetsView)
        addSubview(contentView)
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
            if contentOffsetKVODisabled { return }
            if swipeHeaderBarScrollDisabled == false {
                let newOffsetY = (change![NSKeyValueChangeKey.newKey] as? CGPoint ?? .zero).y
                let topMarginOffset = swipeHeaderTopInset + barInset
                // stick the bar
                if newOffsetY < -topMarginOffset {
                    if let swipeHeaderBar = swipeHeaderBar {
                        swipeHeaderBar.frame.origin.y  = -newOffsetY - (swipeHeaderBar.height)
                        swipeHeaderView?.frame.origin.y = (swipeHeaderBar.frame.origin.y) - (swipeHeaderView?.height)!
                    } else {
                        swipeHeaderView?.frame.origin.y = -newOffsetY - (swipeHeaderView?.height)!
                    }
                } else {
                    swipeHeaderBar?.frame.origin.y  = topMarginOffset - (swipeHeaderBar?.height)!
                    // 'fmax' is used to fix the bug below iOS8.3 : the position of the bar will not correct when the swipeHeaderView is outside of the screen.
                    swipeHeaderView?.frame.origin.y = fmax(-(newOffsetY + barInset), 0) - (swipeHeaderView?.height)!
                }
            }
            
            /*
             * 在自适应contentSize的状态下，itemView初始化后（初始化会导致contentOffset变化，此时又可能会做相邻itemView自适应处理），contentOffset变化受影响，这里做处理保证contentOffset准确
             */
            if isAdjustingcontentSize {
                // 当前scrollview所对应的index
                var index = currentItemIndex
                if let object = object as? UIScrollView, object != currentItemView {
                    index = shouldVisibleItemIndex
                }
                
                if let scrollView = object as? UIScrollView, let offsetObj = contentOffsetQuene[index] {
                    let contentOffsetY = scrollView.contentOffset.y
                    let requireOffset = offsetObj
                    // round 之后，解决像素影响问题
                    if round(contentOffsetY) != round(requireOffset.y) {
                        scrollView.contentOffset.y = round(requireOffset.y)
                    }
                }
            }
        } else if keyPath == "contentSize" {
            // adjust contentSize
            if shouldAdjustContentSize {
                // 当前scrollview所对应的index
                if let scrollView = object as? UIScrollView {
                    var index = currentItemIndex
                    if scrollView != currentItemView {
                        index = shouldVisibleItemIndex
                    }
                    let contentSizeH = scrollView.contentSize.height
                    var minRequireSize = contentMinSizeQuene[index] ?? .zero //[_contentMinSizeQuene[@(index)] CGSizeValue]
                    let minRequireSizeH = round(minRequireSize.height)
                    if contentSizeH < minRequireSizeH {
                        isAdjustingcontentSize = true
                        minRequireSize.height = minRequireSizeH
                        if let scrollView = scrollView as? STCollectionView {
                            scrollView.minRequireContentSize = minRequireSize
                        } else {
                            scrollView.contentSize = minRequireSize
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0, execute: {
                            self.isAdjustingcontentSize = false
                        })
                    }
                }
                
            }
        } else if keyPath == "panGestureRecognizer.state" {
            if let state = change![NSKeyValueChangeKey.newKey] as? UIGestureRecognizerState {
                switch (state) {
                case .began:
                    contentOffsetQuene.removeValue(forKey: currentItemIndex)
                default:
                    break
                }
            }
        }
    }
    
}

extension SwipeTableView: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.swipeTableViewDidScroll?(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.swipeTableViewWillBeginDragging?(self)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.swipeTableViewDidEndDragging?(self, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.swipeTableViewWillBeginDecelerating?(self)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.swipeTableViewDidEndDecelerating?(self)
    }
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
