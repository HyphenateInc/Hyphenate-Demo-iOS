/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatImageBubbleView.h"

#import "AgoraMessageModel.h"

#define MAX_SIZE 250

@interface AgoraChatImageBubbleView ()

@end

@implementation AgoraChatImageBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.cornerRadius = 10.f;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize;
    AgoraChatImageMessageBody *body = (AgoraChatImageMessageBody*)self.model.message.body;
    if (self.model.message.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = body.size;
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    if (self.model.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return CGSizeMake(retSize.width, retSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - setter

- (void)setModel:(AgoraMessageModel *)model
{
    [super setModel:model];
    AgoraChatImageMessageBody *body = (AgoraChatImageMessageBody*)model.message.body;
    
    NSData *imageData = [NSData dataWithContentsOfFile:body.localPath];
    if (imageData.length) {
        self.backImageView.image = [UIImage imageWithData:imageData];
    }
    
    if ([body.thumbnailLocalPath length] > 0) {
        self.backImageView.image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
    }
}

+ (CGFloat)heightForBubbleWithMessageModel:(AgoraMessageModel *)model
{
    CGSize retSize;
    AgoraChatImageMessageBody *body = (AgoraChatImageMessageBody*)model.message.body;
    if (model.message.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = body.size;
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    if (model.message.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return retSize.height;
}

@end
