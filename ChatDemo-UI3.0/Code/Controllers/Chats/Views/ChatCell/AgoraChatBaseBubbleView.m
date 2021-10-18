/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatBaseBubbleView.h"

#import "AgoraMessageModel.h"

@interface AgoraChatBaseBubbleView ()

@end

@implementation AgoraChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backImageView];
        _backImageView.backgroundColor = PaleGreyTwoColor;
        _backImageView.layer.cornerRadius = 10.f;
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPress:)];
        lpgr.minimumPressDuration = .5;
        [self addGestureRecognizer:lpgr];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - setter

- (void)setModel:(AgoraMessageModel *)model
{
    _model = model;
    _backImageView.backgroundColor = model.message.direction == AgoraChatMessageDirectionSend ? KermitGreenTwoColor : PaleGreyTwoColor;
}

+ (CGFloat)heightForBubbleWithMessageModel:(AgoraMessageModel *)model
{
    return 100.f;
}

#pragma mark - action

- (void)bubbleViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didBubbleViewPressed:)]) {
        [self.delegate didBubbleViewPressed:self.model];
    }
}

- (void)bubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didBubbleViewLongPressed)]) {
            [self.delegate didBubbleViewLongPressed];
        }
    }
}

@end
