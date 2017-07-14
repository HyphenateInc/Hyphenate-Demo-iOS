//
//  EMSDKHelper.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/22.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

let sender = EMClient.shared().currentUsername

class EMSDKHelper: NSObject {
    class func createTextMessage(_ text: String, to receiver: String, _ chatType: EMChatType, _ ext: Dictionary<String, Any>?) -> EMMessage{
        let body = EMTextMessageBody.init(text: text)
        let msg = EMMessage.init(conversationID: receiver, from: sender, to: receiver, body: body, ext: ext)
        msg!.chatType = chatType
        return msg!
    }
    
    class func createCMDMessage(_ action: String, to receiver: String, _ chatType: EMChatType, _ ext: Dictionary<String, Any>?, _ cmdParams: Dictionary<String, Any>?) -> EMMessage{
        let body = EMCmdMessageBody.init(action: action)
        let msg = EMMessage.init(conversationID: receiver, from: sender, to: receiver, body: body, ext: ext)
        msg!.chatType = chatType
        return msg!
    }
    
    class func createLocationMessage(_ latitude: Double, _ longitude: Double, _ address: String , to receiver: String, _ chatType: EMChatType, _ ext: Dictionary<String, Any>?) -> EMMessage {
        let body = EMLocationMessageBody.init(latitude: latitude, longitude: longitude, address: address)
        let msg = EMMessage.init(conversationID: receiver, from: sender, to: receiver, body: body, ext: ext)
        msg!.chatType = chatType
        return msg!
    }
    
    class func createImageMessage(_ image: UIImage, _ displayName: String, to receiver: String, _ chatType: EMChatType, _ ext: Dictionary<String, Any>?) -> EMMessage {
        let data = UIImageJPEGRepresentation(image, 1)
        let body = EMImageMessageBody.init(data: data, displayName: displayName)
        body?.size = image.size
        let msg = EMMessage.init(conversationID: receiver, from: sender, to: receiver, body: body, ext: ext)
        msg!.chatType = chatType
        return msg!
    }
    
    class func createVoiceMessage(_ localPath: String, _ displayName: String, _ duration: Int, to receiver: String, _  chatType: EMChatType, _ ext: Dictionary<String, Any>?) -> EMMessage {
        let body = EMVoiceMessageBody.init(localPath: localPath, displayName: displayName)
        if duration > 0 {
            body?.duration = Int32(duration)
        }
        let msg = EMMessage.init(conversationID: receiver, from: sender, to: receiver, body: body, ext: ext)
        msg!.chatType = chatType
        return msg!
    }

    class func createVideoMessage(_ localPath: String, _ displayName: String, _ duration: Int, to receiver: String, _  chatType: EMChatType, _ ext: Dictionary<String, Any>?) -> EMMessage {
        let body = EMVideoMessageBody.init(localPath: localPath, displayName: displayName)
        body?.duration = Int32(duration);
        let msg = EMMessage.init(conversationID: receiver, from: sender, to: receiver, body: body, ext: ext)
        msg!.chatType = chatType
        return msg!
    }

}
