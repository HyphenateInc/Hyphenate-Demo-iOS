/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import "AgoraContactsUIProtocol.h"


typedef enum : NSUInteger {
    AgoraContactInfoTypeUser,
    AgoraContactInfoTypeDelete,
    AgoraContactInfoTypeAddBlacklist,
} AgoraContactInfoType;


@interface AgoraContactInfoCell : AgoraChatCustomBaseCell

@property (nonatomic, strong) NSDictionary *infoDic;

@property (nonatomic, strong) NSString *hyphenateId;

@property (nonatomic, assign) id<AgoraContactsUIProtocol> delegate;

@end

