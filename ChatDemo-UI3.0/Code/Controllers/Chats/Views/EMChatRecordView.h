/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@protocol EMChatRecordViewDelegate <NSObject>

- (void)didFinishRecord:(NSString*)recordPath duration:(NSInteger)duration;

@end

@interface EMChatRecordView : UIView

@property (weak, nonatomic) id<EMChatRecordViewDelegate> delegate;

@end
