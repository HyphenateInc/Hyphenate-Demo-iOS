/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@class AgoraUserModel;
@class AgoraGroupModel;

@protocol AgoraGroupUIProtocol <NSObject>

@optional

- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray;

- (void)removeSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray;

- (void)joinPublicGroup:(AgoraGroupModel *)groupModel;

@end
