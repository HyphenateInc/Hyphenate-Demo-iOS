/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface EMSDKHelper : NSObject

+ (EMMessage *)sendTextMessage:(NSString *)text
                            to:(NSString *)to
                   messageType:(EMChatType)messageType
                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendCmdMessage:(NSString *)action
                           to:(NSString *)to
                  messageType:(EMChatType)messageType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params;

+ (EMMessage *)sendLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)to
                                   messageType:(EMChatType)messageType
                                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                 messageType:(EMChatType)messageType
                  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                 messageType:(EMChatType)messageType
                                  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                messageType:(EMChatType)messageType
                                 messageExt:(NSDictionary *)messageExt;

@end
