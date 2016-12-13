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

@protocol EMFacialViewDelegate

@optional

- (void)selectedFacialView:(NSString*)str;
- (void)deleteSelected:(NSString *)str;
- (void)sendFace;
- (void)sendFace:(NSString *)str;

@end

@class EaseEmotionManager;

@interface EMFacialView : UIView
{
	NSMutableArray *_faces;
}

@property(nonatomic) id<EMFacialViewDelegate> delegate;

@property(strong, nonatomic, readonly) NSArray *faces;

- (void)loadFacialView;

@end
