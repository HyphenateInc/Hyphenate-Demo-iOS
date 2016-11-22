/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@class EMUserModel;
@class EMGroupModel;

@protocol EMGroupUIProtocol <NSObject>

@optional

- (void)addSelectOccupants:(NSArray<EMUserModel *> *)modelArray;

- (void)removeSelectOccupants:(NSArray<EMUserModel *> *)modelArray;

- (void)joinPublicGroup:(EMGroupModel *)groupModel;

@end
