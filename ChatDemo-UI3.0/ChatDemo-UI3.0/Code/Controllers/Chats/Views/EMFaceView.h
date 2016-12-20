/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

#import "EMFacialView.h"

@protocol EMFaceDelegate

@optional
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
- (void)sendFace;
- (void)sendFaceWithEmoji:(NSString *)emoji;

@end

@interface EMFaceView : UIView <EMFacialViewDelegate>

@property (nonatomic, assign) id<EMFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

- (void)setEmojiManagers:(NSArray*)emojiManagers;

@end
