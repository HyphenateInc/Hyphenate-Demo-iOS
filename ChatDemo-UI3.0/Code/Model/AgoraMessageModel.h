/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface AgoraMessageModel : NSObject

@property (strong, nonatomic) Message *message;

@property (assign, nonatomic) BOOL isPlaying;

- (instancetype)initWithMessage:(Message*)message;

@end
