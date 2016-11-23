/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@interface EMMessageTextView : UITextView

@property (nonatomic, copy) NSString *placeHolder;

@property (nonatomic, strong) UIColor *placeHolderTextColor;

- (NSUInteger)numberOfLinesOfText;

+ (NSUInteger)maxCharactersPerLine;

+ (NSUInteger)numberOfLinesForMessage:(NSString *)text;

@end
