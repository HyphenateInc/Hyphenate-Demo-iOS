/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@class EMMessageModel;
@protocol EMChatBaseBubbleViewDelegate <NSObject>

@optional

- (void)didBubbleViewPressed:(EMMessageModel*)models;

- (void)didBubbleViewLongPressed;

@end

@interface EMChatBaseBubbleView : UIView

@property (strong, nonatomic) UIImageView *backImageView;

@property (strong, nonatomic) EMMessageModel *model;

@property (weak, nonatomic) id<EMChatBaseBubbleViewDelegate> delegate;

+ (CGFloat)heightForBubbleWithMessageModel:(EMMessageModel *)model;

@end
