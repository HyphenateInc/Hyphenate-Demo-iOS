/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface AgoraSDKHelper : NSObject

+ (AgoraChatMessage *)initTextMessage:(NSString *)text
                            to:(NSString *)to
                      chatType:(AgoraChatType)chatType
                    messageExt:(NSDictionary *)messageExt;

+ (AgoraChatMessage *)initCmdMessage:(NSString *)action
                           to:(NSString *)to
                     chatType:(AgoraChatType)chatType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params;

+ (AgoraChatMessage *)initLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)to
                                      chatType:(AgoraChatType)chatType
                                    messageExt:(NSDictionary *)messageExt;

+ (AgoraChatMessage *)initImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                    chatType:(AgoraChatType)chatType
                  messageExt:(NSDictionary *)messageExt;

+ (AgoraChatMessage *)initVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                    chatType:(AgoraChatType)chatType
                                  messageExt:(NSDictionary *)messageExt;

+ (AgoraChatMessage *)initVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                   chatType:(AgoraChatType)chatType
                                 messageExt:(NSDictionary *)messageExt;

@end
