/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraFaceView.h"

#define kButtomNum 5

@interface AgoraFaceView ()
{
    AgoraFacialView *_facialView;
    UIScrollView *_bottomScrollView;
    NSInteger _currentSelectIndex;
    NSArray *_emojiManagers;

}

@end

@implementation AgoraFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _facialView = [[AgoraFacialView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, 150)];
        _facialView.delegate = self;
        [self addSubview:_facialView];
        [self _setupButtom];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadEmojiData];
    }
}


#pragma mark - private

- (void)_setupButtom
{
    _currentSelectIndex = 1000;
    
    _bottomScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(_facialView.frame), 4 * CGRectGetWidth(_facialView.frame)/5, self.frame.size.height - CGRectGetHeight(_facialView.frame))];
    _bottomScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_bottomScrollView];
    [self _setupButtonScrollView];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake((kButtomNum-1)*CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetMaxY(_facialView.frame), CGRectGetWidth(_facialView.frame)/kButtomNum, CGRectGetHeight(_bottomScrollView.frame));
    [sendButton setTitle:NSLocalizedString(@"chat.send", @"Send") forState:UIControlStateNormal];
    [sendButton setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendFace) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    
}

- (void)_setupButtonScrollView
{
    NSInteger number = [_emojiManagers count];
    if (number <= 1) {
        return;
    }
    for (int i = 0; i < number; i++) {
        UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
        defaultButton.frame = CGRectMake(i * CGRectGetWidth(_bottomScrollView.frame)/(kButtomNum-1), 0, CGRectGetWidth(_bottomScrollView.frame)/(kButtomNum-1), CGRectGetHeight(_bottomScrollView.frame));
        [defaultButton setBackgroundColor:[UIColor clearColor]];
        defaultButton.layer.borderWidth = 0.5;
        defaultButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [defaultButton addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
        defaultButton.tag = 1000 + i;
        [_bottomScrollView addSubview:defaultButton];
    }
    [_bottomScrollView setContentSize:CGSizeMake(number*CGRectGetWidth(_bottomScrollView.frame)/(kButtomNum-1), CGRectGetHeight(_bottomScrollView.frame))];
}

- (void)_clearupButtomScrollView
{
    for (UIView *view in [_bottomScrollView subviews]) {
        [view removeFromSuperview];
    }
}

#pragma mark - action

- (void)didSelect:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSInteger index = btn.tag - 1000;
    if (index < [_emojiManagers count]) {
        [_facialView loadFacialView];
    }
}

- (void)reloadEmojiData
{
    NSInteger index = _currentSelectIndex - 1000;
    if (index < [_emojiManagers count]) {
        [_facialView loadFacialView];
    }
}

#pragma mark - FacialViewDelegate

- (void)selectedFacialView:(NSString*)str{
    if (_delegate) {
        [_delegate selectedFacialView:str isDelete:NO];
    }
}

- (void)deleteSelected:(NSString *)str{
    if (_delegate) {
        [_delegate selectedFacialView:str isDelete:YES];
    }
}

- (void)sendFace
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

- (void)sendFace:(NSString *)str
{
    if (_delegate) {
        [_delegate sendFaceWithEmoji:str];
    }
}

#pragma mark - public

- (BOOL)stringIsFace:(NSString *)string
{
    if ([_facialView.faces containsObject:string]) {
        return YES;
    }
    
    return NO;
}

- (void)setEmojiManagers:(NSArray *)emojiManagers
{
    _emojiManagers = emojiManagers;
    [self _setupButtonScrollView];
}


@end
