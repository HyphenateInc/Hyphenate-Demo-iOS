//
//  EMChatAudioBubbleView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/26.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate
import DACircularProgress

let TIMER_TI: CGFloat = 0.04

class EMChatAudioBubbleView: EMChatBaseBubbleView {
 
    var playView: UIImageView = {() -> UIImageView in
        let _playView = UIImageView()
        _playView.image = UIImage(named:"Icon_Play")
        _playView.contentMode = UIViewContentMode.scaleAspectFill
        _playView.setNeedsDisplay()
        return _playView
    }()
    var durationLabel: UILabel = {() -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    var progress: CGFloat = 0
    var playTimer: Timer?
    var progressView: DACircularProgressView = {() -> DACircularProgressView in
        let pv = DACircularProgressView.init(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
        pv.isUserInteractionEnabled = false
        pv.thicknessRatio = 0.2
        pv.roundedCorners = 0
        return pv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(durationLabel)
        addSubview(playView)
        addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 79, height: 35)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        durationLabel.frame = CGRect(x: 40, y: 12, width: 24, height: 11)
        playView.frame = CGRect(x: 5, y: 5, width: 25, height: 25)
    }
    override func set(model: EMMessageModel) {
        super.set(model: model)
        let body = _model!.message!.body as! EMVoiceMessageBody
        durationLabel.text = formatDuration(duration: Int(body.duration))
        durationLabel.textColor = _model!.message!.direction == EMMessageDirectionSend ? WhiteColor : AlmostBlackColor
        if model.isPlaying {
            startPlayAudio()
        }else {
            stopPlayAudio()
        }
    }
    
    func formatDuration(duration: Int) -> String {
        var ret = ""
        if duration < 60 {
            ret = "0:" + "\(duration)"
        } else if (duration >= 60 && duration < 3600) {
            let minutes = duration / 60
            let seconds = duration % 60
            ret = "\(minutes)" + "\(seconds)"
        } else {
            let hours = duration / 3600
            let minutes = (duration % 3600) / 60
            let seconds = duration % 60
            
            ret = "\(hours)" + "\(minutes)" + "\(seconds)"
        }
        
        return ret
    }
    
    func playAuido() {
        let body = _model!.message!.body as! EMVoiceMessageBody
        progressView.setProgress(progress, animated: true)
        progress = progress + 1 / (CGFloat(body.duration) / TIMER_TI)
        if progress >= 1 {
            stopPlayAudio()
        }
    }
    
    func startPlayAudio() {
        playTimer = Timer.scheduledTimer(timeInterval: TimeInterval(TIMER_TI), target: self, selector: #selector(playAuido), userInfo: nil, repeats: true)
        progressView.isHidden = false
        progress = 0
        playView.isHidden = true
    }
    
    func stopPlayAudio() {
        playTimer?.invalidate()
        progressView.isHidden = true
        playView.isHidden = false
    }
    
     class func  heightForBubble(withMessageModel model: EMMessageModel) -> CGFloat {
        return 35
    }
}
