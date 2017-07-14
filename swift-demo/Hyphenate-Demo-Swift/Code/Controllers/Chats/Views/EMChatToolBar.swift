//
//  EMChatToolBar.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/19.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit

@objc protocol EMChatToolBarDelegate {
    @objc optional
    func didSendText(text:String)
    func didSendAudio(recordPath: String, duration:Int)
    func didTakePhotos()
    func didSelectPhotos()
    func didSelectLocation()
    func didUpdateInputTextInfo(inputInfo: String)
    
    @objc
    func chatToolBarDidChangeFrame(toHeight height: CGFloat)
}

let kDefaultToolBarHeight = 83
let kDefaultTextViewWidth = kScreenWidth - 30

class EMChatToolBar: UIView , UITextViewDelegate, EMChatRecordViewDelegate, EMFaceDelegate{
    
    weak var delegate: EMChatToolBarDelegate?
    
    private var activityButtonView:UIView?
    private var isShowButtomView = false
    
    @IBOutlet weak var inputTextView: EMMessageTextView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var fileButton: UIButton!
    @IBOutlet weak var line: UIView!
    
    lazy var recordView: EMChatRecordView = {()-> EMChatRecordView in
        let chatRecordView = Bundle.main.loadNibNamed("EMChatRecordView", owner: nil, options: nil)?.first as! EMChatRecordView
        chatRecordView.delegate = self
        return chatRecordView
    }()

    lazy var faceView: EMFaceView = {() -> EMFaceView in
        let _faceView = EMFaceView.init(frame: CGRect(x: 0, y: 0, width: self.width(), height: 180))
        _faceView.delegate = self
        _faceView.backgroundColor = UIColor.init(colorLiteralRed: 240 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)
        
        return _faceView
    }()
    
    lazy var moreItems: Array<UIButton> = {()-> Array<UIButton> in
        let ary = [self.cameraButton, self.photoButton, self.emojiButton, self.recordButton, self.locationButton, self.fileButton]
        return ary as! Array<UIButton>
    }()
    
    class func instance() -> EMChatToolBar {
        let toolBar = Bundle.main.loadNibNamed("EMChatToolBar", owner: nil, options: nil)?.first as? EMChatToolBar
        return toolBar!
    }
    
    public func setupInput(textInfo: String?) {
        inputTextView.set(text: textInfo)
    }
    
    public func fetchInputTextInfo() -> String? {
        return inputTextView.text
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextView.delegate = self
         NotificationCenter.default.addObserver(self, selector: #selector(chatKeyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        inputTextView.layer.borderColor = TextViewBorderColor.cgColor
        inputTextView.layer.borderWidth = 0.5
        
        cameraButton.left(left: (kScreenWidth/5 - cameraButton.width()) / 2)
        photoButton.left(left: (kScreenWidth/5 - photoButton.width()) / 2 + kScreenWidth / 5 * 1)
        emojiButton.left(left: (kScreenWidth/5 - emojiButton.width()) / 2 + kScreenWidth / 5 * 2)
        recordButton.left(left: (kScreenWidth/5 - recordButton.width()) / 2 + kScreenWidth / 5 * 3)
        locationButton.left(left: (kScreenWidth/5 - locationButton.width()) / 2 + kScreenWidth / 5 * 4)
        
        inputTextView.set(placeHolder: "Send Message")
        inputTextView.set(plcaeHolderTextColor: CoolGrayColor)
        line.width(width: kScreenWidth)

        sendButton.left(left: kScreenWidth - sendButton.width() - 15)
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(UIColor.clear.cgColor)
        ctx?.fill(rect)
        
        inputTextView.width(width: kDefaultTextViewWidth)
    }
    
    // MARK: - getter
    
    
    // MARK: - UIKeyboardNotification
    func chatKeyboardWillChangeFrame(noti: Notification) {
        let userInfo = (noti.userInfo as! Dictionary<String, NSValue>)
        let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]!.cgRectValue
        let beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        weak var weakSelf = self
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: { 
            weakSelf?._willShowKeyboard(fromFrame: beginFrame, endFrame: endFrame)
        }, completion: nil)
        
    }
    
    // MARK: - Actions
    
    @IBAction func sendAction(_ sender: UIButton) {
        if inputTextView.text.characters.count > 0 {
            if delegate != nil {
                delegate?.didSendText!(text: inputTextView.text)
            }
            inputTextView.text = "";
        }
    }
    
    @IBAction func cameraAction(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didTakePhotos()
        }
    }
    
    @IBAction func photoAction(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didSelectPhotos()
        }
    }
    
    @IBAction func emojiAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for  btn in moreItems {
            if btn != sender {
                btn.isSelected = false
            }
        }
        
        if sender.isSelected {
            inputTextView.resignFirstResponder()
            _willShow(bottomView: faceView)
        } else {
            _willShow(bottomView: nil)
        }
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for  btn in moreItems {
            if btn != sender {
                btn.isSelected = false
            }
        }
        
        if sender.isSelected {
            recordView.height(height: 187)
            recordView.width(width: kScreenWidth)
            inputTextView.resignFirstResponder()
            _willShow(bottomView: recordView)
        } else {
            _willShow(bottomView: nil)
        }
    }
    
    @IBAction func locationAction(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didSelectLocation()
        }
    }
    
    @IBAction func fileAction(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didTakePhotos()
        }
    }
    
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        for btn in moreItems {
            btn.isSelected = false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        sendButton.isHidden = false
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25) { 
            weakSelf?.inputTextView.setNeedsDisplay()
            weakSelf?.inputTextView.width(width: kDefaultTextViewWidth - self.sendButton.width() - 15)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        sendButton.isHidden = true
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25) {
            weakSelf?.inputTextView.setNeedsDisplay()
            weakSelf?.inputTextView.width(width: kDefaultTextViewWidth)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.setNeedsDisplay()
    }
    
    // MARK: - EMFaceDelegate
    func selected(facialStr: String?, isDelete: Bool) {
        let chatText = inputTextView.text
        if !isDelete && (facialStr?.characters.count)! > 0{
            inputTextView.set(text: chatText! + facialStr!)
        }else {
            let subStr = chatText! as NSString
            if subStr.length >= 2 {
                let str = subStr.substring(from: subStr.length - 2)
                if faceView.stringIsFace(str: str as String) {
                    inputTextView.set(text: subStr.substring(to: subStr.length - 2) as String)
                    return
                }
            }
            
            if subStr.length > 0  {
                inputTextView.set(text: subStr.substring(to: subStr.length - 1) as String)
            }
        }
    }
    
    func backspace(text attr: NSMutableAttributedString, length: Int) -> NSMutableAttributedString{
        let range = inputTextView.selectedRange
        if range.location == 0 {
            return attr
        }
        
        attr.deleteCharacters(in: NSRange.init(location: range.location - length, length: length))
        return attr
    }
    
    func sendFace() {
        if delegate != nil {
            if inputTextView.text.characters.count != 0 {
                let attStr = NSMutableString.init(string: inputTextView.attributedText.string)
                delegate?.didSendText!(text: attStr as String)
                inputTextView.set(text: "")
            }
        }
    }
    
    func sendFace(withEmoji emoji: String) {
        
    }
    
    // MARK: - EMChatRecordViewDelegate
    func didFinish(recordPatch: String, duration: Int) {
        if delegate != nil {
            delegate?.didSendAudio(recordPath: recordPatch, duration: duration)
        }
    }
    
    // MARK: - Private
    private func _willShowKeyboard(fromFrame beginFrame: CGRect, endFrame toFrame: CGRect) {
        if beginFrame.origin.y == kScreenHeight {
            _willShow(bottomHeight: toFrame.size.height)
            if activityButtonView != nil {
                activityButtonView!.removeFromSuperview()
            }
            activityButtonView = nil
        }
        else if toFrame.origin.y == kScreenHeight {
            _willShow(bottomHeight: 0)
        }
        else {
            _willShow(bottomHeight: toFrame.size.height)
        }
    }
    
    private func _willShow(bottomView: UIView?) {
        if activityButtonView != bottomView {
            let bottomHeight = bottomView != nil ? bottomView?.height() : 0
            _willShow(bottomHeight: bottomHeight!)
            
            if bottomView != nil {
                bottomView?.top(top: CGFloat(kDefaultToolBarHeight))
                addSubview(bottomView!)
            }
            
            if activityButtonView != nil {
                activityButtonView!.removeFromSuperview()
            }
            
            activityButtonView = bottomView
        }
    }
    
    private func _willShow(bottomHeight: CGFloat) {
        let fromFrame = frame
        let toHeight = CGFloat(kDefaultToolBarHeight) + bottomHeight
        let toFrame = CGRect(x: fromFrame.origin.x, y: fromFrame.origin.y + (fromFrame.size.height - toHeight), width: fromFrame.size.width, height: toHeight)
        
        if bottomHeight == 0 && frame.size.height == CGFloat(kDefaultToolBarHeight) {
            return
        }
        
        if bottomHeight == 0 {
            isShowButtomView = false
        }else{
            isShowButtomView = true
        }
        
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25) { 
            weakSelf?.frame = toFrame
        }
        
        _willShowView(toHeight: toHeight)
    }
    
    private func _willShowView(toHeight: CGFloat) {
        if delegate != nil  {
            delegate!.chatToolBarDidChangeFrame(toHeight: toHeight)
        }
    }
}
