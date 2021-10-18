/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

#import "AgoraFacialView.h"

@protocol AgoraFaceDelegate

@optional
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
- (void)sendFace;
- (void)sendFaceWithEmoji:(NSString *)emoji;

@end

@interface AgoraFaceView : UIView <AgoraFacialViewDelegate>

@property (nonatomic, assign) id<AgoraFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

- (void)setEmojiManagers:(NSArray*)emojiManagers;

@end

