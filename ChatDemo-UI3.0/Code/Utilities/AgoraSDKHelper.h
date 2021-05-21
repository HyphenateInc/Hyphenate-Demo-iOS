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

+ (Message *)initTextMessage:(NSString *)text
                            to:(NSString *)to
                      chatType:(AgoraChatType)chatType
                    messageExt:(NSDictionary *)messageExt;

+ (Message *)initCmdMessage:(NSString *)action
                           to:(NSString *)to
                     chatType:(AgoraChatType)chatType
                   messageExt:(NSDictionary *)messageExt
                    cmdParams:(NSArray *)params;

+ (Message *)initLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)to
                                      chatType:(AgoraChatType)chatType
                                    messageExt:(NSDictionary *)messageExt;

+ (Message *)initImageData:(NSData *)imageData
                 displayName:(NSString *)displayName
                          to:(NSString *)receiver
                    chatType:(AgoraChatType)chatType
                  messageExt:(NSDictionary *)messageExt;

+ (Message *)initVoiceMessageWithLocalPath:(NSString *)localPath
                                 displayName:(NSString *)displayName
                                    duration:(NSInteger)duration
                                          to:(NSString *)receiver
                                    chatType:(AgoraChatType)chatType
                                  messageExt:(NSDictionary *)messageExt;

+ (Message *)initVideoMessageWithLocalURL:(NSURL *)url
                                displayName:(NSString *)displayName
                                   duration:(NSInteger)duration
                                         to:(NSString *)receiver
                                   chatType:(AgoraChatType)chatType
                                 messageExt:(NSDictionary *)messageExt;

@end
