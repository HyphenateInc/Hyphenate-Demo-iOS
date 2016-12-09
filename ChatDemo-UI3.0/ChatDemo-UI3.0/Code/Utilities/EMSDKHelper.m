/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMSDKHelper.h"

#import "EMNotificationNames.h"

@implementation EMSDKHelper

+ (EMMessage *)sendTextMessage:(NSString *)text
                            to:(NSString *)receiver
                   messageType:(EMChatType)messageType
                    messageExt:(NSDictionary *)messageExt

{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];

    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

+ (EMMessage *)sendCmdMessage:(NSString *)action
                           to:(NSString *)receiver
                  messageType:(EMChatType)messageType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params
{
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:action];
    if (params) {
        body.params = params;
    }

    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

+ (EMMessage *)sendLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)receiver
                                   messageType:(EMChatType)messageType
                                    messageExt:(NSDictionary *)messageExt
{
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:latitude longitude:longitude address:address];

    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

+ (EMMessage *)sendImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                 messageType:(EMChatType)messageType
                  messageExt:(NSDictionary *)messageExt
{
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:imageData displayName:displayName];
    
    if (CGSizeEqualToSize(body.size, CGSizeZero)) {
        if (imageData.length) {
            UIImage *image = [UIImage imageWithData:imageData];
            body.size = image.size;
        }
    }
    
    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    
    message.chatType = messageType;
    
    return message;
}

+ (EMMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                 messageType:(EMChatType)messageType
                                  messageExt:(NSDictionary *)messageExt
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:localPath displayName:displayName];
    
    if (duration > 0) {
        body.duration = (int)duration;
    }
    
    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

+ (EMMessage *)sendVideoMessageWithLocalURL:(NSURL *)url
                           displayName:(NSString *)displayName
                              duration:(NSInteger)duration
                                    to:(NSString *)receiver
                           messageType:(EMChatType)messageType
                            messageExt:(NSDictionary *)messageExt
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:[url path] displayName:displayName];
    
    if (duration > 0) {
        body.duration = (int)duration;
    }
    
    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

@end
