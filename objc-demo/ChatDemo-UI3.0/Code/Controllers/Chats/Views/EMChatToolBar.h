/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@protocol EMChatToolBarDelegate <NSObject>

@optional

- (void)didSendText:(NSString*)text;

- (void)didSendAudio:(NSString*)recordPath duration:(NSInteger)duration;

- (void)didTakePhotos;

- (void)didSelectPhotos;

- (void)didSelectLocation;

@required

- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight;

@end

@interface EMChatToolBar : UIView

@property (weak, nonatomic) id<EMChatToolBarDelegate> delegate;

@end
