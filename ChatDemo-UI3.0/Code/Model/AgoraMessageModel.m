/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraMessageModel.h"

@interface AgoraMessageModel ()
@property (strong, nonatomic) AgoraChatMessage *message;

@end

@implementation AgoraMessageModel

- (instancetype)initWithMessage:(AgoraChatMessage*)message
{
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}


@end
