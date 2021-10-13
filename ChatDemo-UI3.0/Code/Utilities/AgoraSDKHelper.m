/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraSDKHelper.h"

#import "AgoraNotificationNames.h"

@implementation AgoraSDKHelper

+ (AgoraChatMessage *)initTextMessage:(NSString *)text
                            to:(NSString *)receiver
                      chatType:(AgoraChatType)chatType
                    messageExt:(NSDictionary *)messageExt

{
    AgoraChatTextMessageBody *body = [[AgoraChatTextMessageBody alloc] initWithText:text];

    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (AgoraChatMessage *)initCmdMessage:(NSString *)action
                           to:(NSString *)receiver
                     chatType:(AgoraChatType)chatType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params
{
    AgoraChatCmdMessageBody *body = [[AgoraChatCmdMessageBody alloc] initWithAction:action];
    
    if (params) {
        body.params = params;
    }

    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (AgoraChatMessage *)initLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)receiver
                                      chatType:(AgoraChatType)chatType
                                    messageExt:(NSDictionary *)messageExt
{
    AgoraChatLocationMessageBody *body = [[AgoraChatLocationMessageBody alloc] initWithLatitude:latitude
                                                                        longitude:longitude
                                                                          address:address];

    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (AgoraChatMessage *)initImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                    chatType:(AgoraChatType)chatType
                  messageExt:(NSDictionary *)messageExt
{
    AgoraChatImageMessageBody *body = [[AgoraChatImageMessageBody alloc] initWithData:imageData displayName:displayName];
    
    if (CGSizeEqualToSize(body.size, CGSizeZero)) {
        if (imageData.length) {
            UIImage *image = [UIImage imageWithData:imageData];
            body.size = image.size;
        }
    }
    
    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    
    message.chatType = chatType;
    
    return message;
}

+ (AgoraChatMessage *)initVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                    chatType:(AgoraChatType)chatType
                                  messageExt:(NSDictionary *)messageExt
{
    AgoraChatVoiceMessageBody *body = [[AgoraChatVoiceMessageBody alloc] initWithLocalPath:localPath displayName:displayName];
    
    if (duration > 0) {
        body.duration = (int)duration;
    }
    
    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (AgoraChatMessage *)initVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                   chatType:(AgoraChatType)chatType
                                 messageExt:(NSDictionary *)messageExt
{
    AgoraChatVideoMessageBody *body = [[AgoraChatVideoMessageBody alloc] initWithLocalPath:[url path] displayName:displayName];
    
    if (duration > 0) {
        body.duration = (int)duration;
    }
    
    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

@end
