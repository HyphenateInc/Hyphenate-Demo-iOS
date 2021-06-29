/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@protocol AgoraChatRecordViewDelegate <NSObject>

- (void)didFinishRecord:(NSString*)recordPath duration:(NSInteger)duration;

@end

@interface AgoraChatRecordView : UIView

@property (weak, nonatomic) id<AgoraChatRecordViewDelegate> delegate;

@end
