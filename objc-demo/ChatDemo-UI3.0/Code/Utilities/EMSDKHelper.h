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

+ (EMMessage *)initTextMessage:(NSString *)text
                            to:(NSString *)to
                      chatType:(EMChatType)chatType
                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)initCmdMessage:(NSString *)action
                           to:(NSString *)to
                     chatType:(EMChatType)chatType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params;

+ (EMMessage *)initLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)to
                                      chatType:(EMChatType)chatType
                                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)initImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                    chatType:(EMChatType)chatType
                  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)initVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                    chatType:(EMChatType)chatType
                                  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)initVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                   chatType:(EMChatType)chatType
                                 messageExt:(NSDictionary *)messageExt;

@end
