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

+ (EMMessage *)initTextMessage:(NSString *)text
                            to:(NSString *)receiver
                      chatType:(EMChatType)chatType
                    messageExt:(NSDictionary *)messageExt

{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];

    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (EMMessage *)initCmdMessage:(NSString *)action
                           to:(NSString *)receiver
                     chatType:(EMChatType)chatType
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
    message.chatType = chatType;
    
    return message;
}

+ (EMMessage *)initLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)receiver
                                      chatType:(EMChatType)chatType
                                    messageExt:(NSDictionary *)messageExt
{
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:latitude
                                                                        longitude:longitude
                                                                          address:address];

    NSString *sender = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:receiver
                                                              from:sender
                                                                to:receiver
                                                              body:body
                                                               ext:messageExt];
    message.chatType = chatType;
    
    return message;
}

+ (EMMessage *)initImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                    chatType:(EMChatType)chatType
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
    
    message.chatType = chatType;
    
    return message;
}

+ (EMMessage *)initVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                    chatType:(EMChatType)chatType
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
    message.chatType = chatType;
    
    return message;
}

+ (EMMessage *)initVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                   chatType:(EMChatType)chatType
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
    message.chatType = chatType;
    
    return message;
}

@end
