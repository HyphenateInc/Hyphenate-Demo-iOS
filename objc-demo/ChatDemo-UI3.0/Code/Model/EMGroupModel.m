/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMGroupModel.h"

@implementation EMGroupModel

- (instancetype)initWithObject:(NSObject *)obj {
    if ([obj isKindOfClass:[EMGroup class]]) {
        self = [super init];
        if (self) {
            _group = (EMGroup *)obj;
            _hyphenateId = _group.groupId;
            _subject = _group.subject;
            _defaultAvatarImage = [UIImage imageNamed:@"default_group_avatar.png"];
        }
        return self;
    }
    return nil;
}

- (NSString *)subject {
    if (_subject.length == 0) {
        return _hyphenateId;
    }
    return _subject;
}

- (NSString *)searchKey {
    if (self.subject.length > 0) {
        return self.subject;
    }
    return _hyphenateId;
}

@end
