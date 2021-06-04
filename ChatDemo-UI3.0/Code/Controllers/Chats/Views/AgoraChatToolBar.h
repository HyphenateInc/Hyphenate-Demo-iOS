//
//  AgroaChatToolNew.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/24.
//  Copyright © 2021 easemob. All rights reserved.
//

/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@protocol AgoraChatToolBarNewDelegate <NSObject>

@optional

- (void)didSendText:(NSString*)text;

- (void)didSendAudio:(NSString*)recordPath duration:(NSInteger)duration;

- (void)didTakePhotos;

- (void)didSelectPhotos;

- (void)didSelectLocation;

@required

- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight;

@end

@interface AgoraChatToolBar : UIView

@property (weak, nonatomic) id<AgoraChatToolBarNewDelegate> delegate;

@end
