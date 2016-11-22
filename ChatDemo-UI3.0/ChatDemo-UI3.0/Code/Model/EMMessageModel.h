/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface EMMessageModel : NSObject

@property (strong, nonatomic) EMMessage *message;

@property (assign, nonatomic) BOOL isPlaying;

- (instancetype)initWithMessage:(EMMessage*)message;

@end
