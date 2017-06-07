/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@class EMUserModel;
#import "EMGroupUIProtocol.h"

typedef NS_ENUM(NSUInteger, EMContactSelectStyle) {
    EMContactSelectStyle_Add      =       0,
    EMContactSelectStyle_Invite
};

@interface EMMemberSelectViewController : UIViewController

@property (nonatomic, assign) EMContactSelectStyle style;

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

- (instancetype)initWithInvitees:(NSArray *)aHasInvitees
                  maxInviteCount:(NSInteger)aCount;

@end
