//
//  EMChatRecordView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/19.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol EMChatRecordViewDelegate {
    func didFinish(recordPatch: String, duration: Int)
}

class EMChatRecordView: UIView {
    
    weak var delegate: EMChatRecordViewDelegate?
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    private var _recordTimer: Timer?
    private var _recordLength: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recordButton.left(left: (kScreenWidth - recordButton.width()) / 2)
        timeLabel.width(width: kScreenWidth)
        recordLabel.width(width: kScreenWidth)
    }
    
    func startTimer() {
        timeLabel.isHidden = false
        _recordLength = 0
        _recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(recordTimerAction), userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        timeLabel.isHidden = true
        timeLabel.text = "00:0"
        _recordTimer?.invalidate()
    }
    
    func resetView() {
        recordLabel.text = "Hold to record"
        recordLabel.textColor = SteelGreyColor
        recordButton.setImage(UIImage(named: "Button_Record"), for: UIControlState.normal)
        backgroundColor = PaleGrayColor
        endTimer()
    }
    
    //MARK: - Actions
    
    @IBAction func recordButtonTouchDown(_ sender: UIButton) {
        recordLabel.text = "Release to send"
        recordLabel.textColor = OrangeRedColor
        recordButton.setImage(UIImage(named: "Button_Record active"), for: UIControlState.normal)
        startTimer()
        
        let x = arc4random() % 100000
        let time = Date.timeIntervalBetween1970AndReferenceDate
        let fileName = "\(time)" + "\(x)"
        EMCDDeviceManager.sharedInstance().asyncStartRecording(withFileName: fileName) { (error) in
            if error != nil { }
        }
    }
    
    @IBAction func recordButtonTouchUpOutside(_ sender: UIButton) {
        EMCDDeviceManager.sharedInstance().cancelCurrentRecording()
        resetView()
    }
    
    @IBAction func recordButtonTouchUpInside(_ sender: UIButton) {
        resetView()
        weak var weakSelf = self
        EMCDDeviceManager.sharedInstance().asyncStopRecording { (recordPath, aDuration, error) in
            if error == nil {
                if weakSelf?.delegate != nil {
                    weakSelf?.delegate?.didFinish(recordPatch: recordPath!, duration: aDuration)
                }
            }
        }
    }
    
    @IBAction func recordButtonDragOutside(_ sender: UIButton) {
        recordLabel.text = "Release to cancel"
        recordLabel.textColor = WhiteColor
        recordButton.setImage(UIImage(named:"Button_Record cancel"), for: UIControlState.normal)
        backgroundColor = BlueyGreyColor
    }
    
    @IBAction func recordButtonDragInside(_ sender: UIButton) {
        recordLabel.text = "Release to send"
        recordLabel.textColor = OrangeRedColor
        recordButton.setImage(UIImage(named:"Button_Record cancel"), for: UIControlState.normal)
        backgroundColor = PaleGrayColor
    }
    
    func recordTimerAction() {
        _recordLength = _recordLength + 1
        let h = _recordLength / 3600
        let m = (_recordLength - h * 3600) / 60
        let s = _recordLength - h * 3600 - m * 60
        
        if h > 0 {timeLabel.text = "\(h)" + ":" + "\(m)" + ":" + "\(s)" }
        else if m > 0 {timeLabel.text = "\(m)" + ":" + "\(s)" }
        else {timeLabel.text = "\(00)" + ":" + "\(s)"}
    }
    
    // MARK: - Private

    private func _canRecord() -> Bool {
        var bCanRecord = true
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            bCanRecord = granted;
        })
        
        return bCanRecord
    }
}
