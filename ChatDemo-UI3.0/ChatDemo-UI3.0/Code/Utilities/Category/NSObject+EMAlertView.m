/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */
#import "NSObject+EMAlertView.h"

@implementation NSObject (EMAlertView)

- (void)showAlertWithMessage:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}


- (void)showAlertWithMessage:(NSString *)msg delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:msg
                                                       delegate:delegate
                                              cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK")
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

@end
