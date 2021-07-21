/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@class AgoraChatBaseCell;
@class AgoraMessageModel;
@protocol AgoraChatBaseCellDelegate <NSObject>

@optional

- (void)didHeadImagePressed:(AgoraMessageModel*)model;

- (void)didTextCellPressed:(AgoraMessageModel*)model;

- (void)didImageCellPressed:(AgoraMessageModel*)model;

- (void)didAudioCellPressed:(AgoraMessageModel*)model;

- (void)didVideoCellPressed:(AgoraMessageModel*)model;

- (void)didLocationCellPressed:(AgoraMessageModel*)model;

- (void)didCellLongPressed:(AgoraChatCustomBaseCell*)cell;

- (void)didResendButtonPressed:(AgoraMessageModel*)model;

@end

@interface AgoraChatBaseCell : UITableViewCell

@property (weak, nonatomic) id<AgoraChatBaseCellDelegate> delegate;

- (instancetype)initWithMessageModel:(AgoraMessageModel*)model;

- (void)setMessageModel:(AgoraMessageModel *)model;

+ (CGFloat)heightForMessageModel:(AgoraMessageModel*)model;

+ (NSString *)cellIdentifierForMessageModel:(AgoraMessageModel *)model;

@end
