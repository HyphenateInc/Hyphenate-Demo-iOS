/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@protocol AgoraFacialViewDelegate

@optional

- (void)selectedFacialView:(NSString*)str;
- (void)deleteSelected:(NSString *)str;
- (void)sendFace;
- (void)sendFace:(NSString *)str;

@end

@class EaseEmojiManager;

@interface AgoraFacialView : UIView
{
	NSMutableArray *_faces;
}

@property(nonatomic) id<AgoraFacialViewDelegate> delegate;

@property(strong, nonatomic, readonly) NSArray *faces;

- (void)loadFacialView;

@end
