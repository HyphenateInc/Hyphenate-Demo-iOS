/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2013-2014 Hyphenate Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from Hyphenate Technologies.
  */

#import <UIKit/UIKit.h>

#import "EMFacialView.h"

@protocol EMFaceDelegate

@optional
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
- (void)sendFace;
- (void)sendFaceWithEmotion:(NSString *)emotion;

@end

@interface EMFaceView : UIView <EMFacialViewDelegate>

@property (nonatomic, assign) id<EMFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

- (void)setEmotionManagers:(NSArray*)emotionManagers;

@end
