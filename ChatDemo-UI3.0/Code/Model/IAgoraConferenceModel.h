/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@protocol IAgoraConferenceModel <NSObject>
@property (nonatomic, strong, readonly) NSString *hyphenateId;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *avatarURLPath;
@property (nonatomic, strong, readonly) UIImage *defaultAvatarImage;

- (instancetype)initWithObject:(NSObject *)obj;

@end
