/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface NSObject (EMAlertView)

- (void)showAlertWithMessage:(NSString *)msg;

- (void)showAlertWithMessage:(NSString *)msg delegate:(id)delegate;

@end
