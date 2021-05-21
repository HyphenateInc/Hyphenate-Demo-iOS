/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@class AgoraMessageModel;
@protocol AgoraChatBaseBubbleViewDelegate <NSObject>

@optional

- (void)didBubbleViewPressed:(AgoraMessageModel*)models;

- (void)didBubbleViewLongPressed;

@end

@interface AgoraChatBaseBubbleView : UIView

@property (strong, nonatomic) UIImageView *backImageView;

@property (strong, nonatomic) AgoraMessageModel *model;

@property (weak, nonatomic) id<AgoraChatBaseBubbleViewDelegate> delegate;

+ (CGFloat)heightForBubbleWithMessageModel:(AgoraMessageModel *)model;

@end
