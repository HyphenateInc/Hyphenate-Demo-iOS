//
//  EMFaceView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/19.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit

let kButtomNum = 5

@objc protocol EMFaceDelegate {
    @objc optional
    func selected(facialStr: String?, isDelete: Bool)
    func sendFace()
    func sendFace(withEmoji emoji:String)
}

class EMFaceView: UIView, EMFacialViewDelegate {

    weak var delegate: EMFaceDelegate?
    
    private var _facialView: EMFacialView?
    private var _bottomScrollView: UIScrollView?
    private var _currentSelectIndex: Int = 0
    private var _emojiManagers: Array<Any>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _facialView = EMFacialView.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 150))
        _facialView?.delegate = self
        
        addSubview(_facialView!)
        _setupButtom()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func willMove(toSuperView newSuperView: UIView?) {
        if newSuperView != nil {
            reloadEmojiData()
        }
    }
    
    // MARK: - Private
    func _setupButtom() {
        _currentSelectIndex = 1000
        _bottomScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: (_facialView?.height())!, width: 4 * (_facialView?.width())! / 5, height: height() - (_facialView?.height())!))
        _bottomScrollView?.showsHorizontalScrollIndicator = false
        addSubview(_bottomScrollView!)
        _setupButtonScrollView()
        
        let sendBtn = UIButton.init(type: UIButtonType.custom)
        sendBtn.frame = CGRect(x: CGFloat((kButtomNum - 1)) * (_facialView?.width())! / CGFloat(kButtomNum), y: ((_facialView?.frame.origin.y)! + (_facialView?.height())!), width: (_facialView?.width())! / CGFloat(kButtomNum), height: (_bottomScrollView?.height())!)
        sendBtn.setTitle("Send", for: UIControlState.normal)
        sendBtn.setTitleColor(KermitGreenTwoColor, for: UIControlState.normal)
        sendBtn.addTarget(self, action: #selector(sendFace as (Void) -> Void), for: UIControlEvents.touchUpInside)
        addSubview(sendBtn)
        
        _facialView?.loadFacialView()
    }
    
    func _setupButtonScrollView() {
        if _emojiManagers == nil {
            return
        }
        
        if (_emojiManagers?.count)! <= 1 {
            return
        }
        
        let number = _emojiManagers?.count
        
        for i in 0..<number! {
            let defaultButton = UIButton.init(type: UIButtonType.custom)
            defaultButton.frame = CGRect.init(x: CGFloat(i) * (_bottomScrollView?.width())! / CGFloat(kButtomNum - 1), y: 0, width: (_bottomScrollView?.width())! / CGFloat(kButtomNum - 1), height: (_bottomScrollView?.height())!)
            defaultButton.backgroundColor = UIColor.clear
            defaultButton.layer.borderWidth = 0.5
            defaultButton.layer.borderColor = UIColor.white.cgColor
            defaultButton.addTarget(self, action: #selector(didSelect(btn:)), for:UIControlEvents.touchUpInside)
            defaultButton.tag = 1000 + i
            _bottomScrollView?.addSubview(defaultButton)
        }
        
        _bottomScrollView?.contentSize = CGSize.init(width: CGFloat(number!) * (_bottomScrollView?.width())! / CGFloat(kButtomNum - 1), height: (_bottomScrollView?.height())!)
    }
    
    func _clearupButtonScrollView() {
        for var view  in (_bottomScrollView?.subviews)! {
            view = (view as UIView)
            view.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    func didSelect(btn: UIButton) {
        let tag = btn.tag
        if tag < (_emojiManagers?.count)! {
            _facialView?.loadFacialView()
        }
    }
    
    func reloadEmojiData() {
        let tag = _currentSelectIndex - 1000
        if tag < (_emojiManagers?.count)! {
            _facialView?.loadFacialView()
        }
    }
    
    // MARK: - FacialViewDelegate
    func selectedFaicalView(str: String?) {
        if delegate != nil {
            delegate!.selected!(facialStr: str, isDelete: false)
        }
    }
    
    func deleteSelected(str: String?) {
        if delegate != nil {
            delegate!.selected!(facialStr: str, isDelete: true)
        }
    }
    
    func sendFace() {
        if delegate != nil {
            delegate!.sendFace()
        }
    }
    
    func sendFace(str: String?) {
        if delegate != nil {
            delegate!.sendFace(withEmoji: str!)
        }
    }
    
    func stringIsFace(str: String) -> Bool{
        if (_facialView?.faces?.contains(str))! {
            return true
        }
        return false
    }
    
    func setEmojiManagers(emojiManagers: Array<Any>) {
        _emojiManagers = emojiManagers
        _setupButtonScrollView()
    }
}
