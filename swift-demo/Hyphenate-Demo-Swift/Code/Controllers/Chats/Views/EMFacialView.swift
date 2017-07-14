//
//  EMFacialView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/19.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit

@objc protocol EMFacialViewDelegate {
    @objc optional
    func selectedFaicalView(str: String?)
    func deleteSelected(str: String?)
    func sendFace()
    func sendFace(str:String?)
}

class EMFacialView: UIView, UIScrollViewDelegate {
    
    weak var delegate: EMFacialViewDelegate?
    var faces: Array<String>?

    var pageControl: UIPageControl?
    
    lazy var scrollView: UIScrollView = {() -> UIScrollView in
        let _scrollView = UIScrollView()
        return _scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        faces = EMEmoji.allEmoji() as? Array<String>
        scrollView.frame = frame
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        pageControl = UIPageControl()
        addSubview(scrollView)
        addSubview(pageControl!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadFacialView(){
        for var view in scrollView.subviews {
            view = view as UIView
            view.removeFromSuperview()
        }
        
        scrollView.setContentOffset(CGPoint.zero, animated: false)
        let maxRow = 4
        let maxCol = 7
        let pageSize = (maxRow - 1) * 7
        
        let itemWith = width() / CGFloat(maxCol)
        let itemHeight = height() / CGFloat(maxRow)
        
        var _frame = frame
        _frame.size.height = _frame.size.height - itemHeight
        scrollView.frame = _frame
        
        let totalPage = (faces?.count)! % pageSize == 0 ? (faces?.count)! / pageSize : (faces?.count)! / pageSize + 1
        scrollView.contentSize = CGSize(width: CGFloat(totalPage) * width(), height: CGFloat(itemHeight) * CGFloat((maxRow - 1)))
        pageControl?.currentPage = 0
        pageControl?.numberOfPages = totalPage
        pageControl?.frame = CGRect(x: 0, y: CGFloat(maxRow - 1) * itemWith + 5, width: width(), height: itemHeight - 10)
        
        for i in 0..<totalPage {
            for row in 0..<maxRow - 1 {
                for col in 0..<maxCol {
                    let index = i * pageSize + row * maxCol + col
                    if index != 0 && (index - (pageSize - 1)) % pageSize == 0 {
                        faces?.insert("", at: index)
                        break
                    }
                    if index < (faces?.count)! {
                        let btn = UIButton.init(type: UIButtonType.custom)
                        btn.backgroundColor = UIColor.clear
                        btn.frame = CGRect.init(x: CGFloat(i) * width() + CGFloat(col) * itemWith, y: CGFloat(row) * itemHeight, width: itemWith, height: itemHeight)
                        btn.titleLabel?.font = UIFont.init(name: "AppleColorEmoji", size: 29)
                        btn.setTitle(faces?[index], for: UIControlState.normal)
                        btn.addTarget(self, action: #selector(selected(btn:)), for: UIControlEvents.touchUpInside)
                        btn.tag = index
                        scrollView.addSubview(btn)
                    }else {
                        break
                    }
                }
            }
            
            let deleteBtn = UIButton.init(type: UIButtonType.custom)
            deleteBtn.backgroundColor = UIColor.clear
            deleteBtn.frame = CGRect.init(x: CGFloat(i) * width() + CGFloat(maxCol - 1) * itemWith, y: CGFloat(maxRow - 2) * itemHeight, width: itemWith, height: itemHeight)
            
            deleteBtn.setImage(UIImage(named: "faceDelete"), for: UIControlState.normal)
            deleteBtn.setImage(UIImage(named: "faceDelete"), for: UIControlState.highlighted)
            
            deleteBtn.tag = 10000
            deleteBtn.addTarget(self, action: #selector(selected(btn:)), for: UIControlEvents.touchUpInside)
            scrollView.addSubview(deleteBtn)
        }
    }

    func selected(btn: UIButton) {
        if btn.tag == 10000 && delegate != nil {
            delegate?.deleteSelected(str: nil)
        } else {
            let str = faces?[btn.tag]
            if delegate != nil {
                delegate?.selectedFaicalView!(str:str)
            }
        }
    }
    
    func sendAction(btn:UIButton) {
        if delegate != nil {
            delegate?.sendFace()
        }
    }
    
    func sendPngAction(btn:UIButton) {
        if btn.tag == 10000 && delegate != nil {
            delegate?.deleteSelected(str: nil)
        }else {
            if delegate != nil {
                var str = faces?[btn.tag]
                str = "\\:" + str!
                delegate?.selectedFaicalView!(str: str)
            }
        }
    }
    
    func sendGifAction(btn:UIButton) {
        if delegate != nil {
            let str = faces?[btn.tag]
            delegate?.sendFace(str: str)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if offset.x == 0 {
            pageControl?.currentPage = 0
        }else {
            let page = offset.x / scrollView.width()
            pageControl?.currentPage = Int(page)
        }
    }
    
}
