/************************************************************
 *  * Hyphenate 
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseUserModel.h"

@implementation EaseUserModel

- (instancetype)initWithUsername:(NSString *)username
{
    self = [super init];
    if (self) {
        _username = username;
        self.nickname = @"";
        self.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
        self.unreadMessageCount = 0;
    }
    
    return self;
}

@end
