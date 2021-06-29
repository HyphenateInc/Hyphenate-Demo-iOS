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

+ (Message *)initTextMessage:(NSString *)text
                            to:(NSString *)receiver
                      chatType:(AgoraChatType)chatType
                    messageExt:(NSDictionary *)messageExt

{
    TextMessageBody *body = [[TextMessageBody alloc] initWithText:text];

    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    Message *message = [[Message alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (Message *)initCmdMessage:(NSString *)action
                           to:(NSString *)receiver
                     chatType:(AgoraChatType)chatType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params
{
    CmdMessageBody *body = [[CmdMessageBody alloc] initWithAction:action];
    
    if (params) {
        body.params = params;
    }

    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    Message *message = [[Message alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (Message *)initLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)receiver
                                      chatType:(AgoraChatType)chatType
                                    messageExt:(NSDictionary *)messageExt
{
    LocationMessageBody *body = [[LocationMessageBody alloc] initWithLatitude:latitude
                                                                        longitude:longitude
                                                                          address:address];

    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    Message *message = [[Message alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (Message *)initImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                    chatType:(AgoraChatType)chatType
                  messageExt:(NSDictionary *)messageExt
{
    ImageMessageBody *body = [[ImageMessageBody alloc] initWithData:imageData displayName:displayName];
    
    if (CGSizeEqualToSize(body.size, CGSizeZero)) {
        if (imageData.length) {
            UIImage *image = [UIImage imageWithData:imageData];
            body.size = image.size;
        }
    }
    
    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    Message *message = [[Message alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    
    message.chatType = chatType;
    
    return message;
}

+ (Message *)initVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                    chatType:(AgoraChatType)chatType
                                  messageExt:(NSDictionary *)messageExt
{
    VoiceMessageBody *body = [[VoiceMessageBody alloc] initWithLocalPath:localPath displayName:displayName];
    
    if (duration > 0) {
        body.duration = (int)duration;
    }
    
    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    Message *message = [[Message alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (Message *)initVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                   chatType:(AgoraChatType)chatType
                                 messageExt:(NSDictionary *)messageExt
{
    VideoMessageBody *body = [[VideoMessageBody alloc] initWithLocalPath:[url path] displayName:displayName];
    
    if (duration > 0) {
        body.duration = (int)duration;
    }
    
    NSString *sender = [[AgoraChatClient sharedClient] currentUsername];
    Message *message = [[Message alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

@end
