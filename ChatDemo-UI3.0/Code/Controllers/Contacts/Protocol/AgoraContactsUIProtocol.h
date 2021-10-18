/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@protocol AgoraContactsUIProtocol <NSObject>

@optional

- (void)needRefreshContacts:(BOOL)isNeedRefresh;

- (void)needRefreshContactsFromServer:(BOOL)isNeedRefresh;

@end
