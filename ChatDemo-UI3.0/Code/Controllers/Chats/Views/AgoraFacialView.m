/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraFacialView.h"
#import "AgoraEmoji.h"
#import "AgoraFaceView.h"

@interface AgoraFacialView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *faces;;

@end

@implementation AgoraFacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollview.frame = frame;
        [self addSubview:self.scrollview];
        [self addSubview:self.pageControl];
        [self loadFacialView];
        
    }
    return self;
}

- (void)loadFacialView
{
    for (UIView *view in [self.scrollview subviews]) {
        [view removeFromSuperview];
    }
    
    [_scrollview setContentOffset:CGPointZero];
	NSInteger maxRow = 4;
    NSInteger maxCol = 7;
    NSInteger pageSize = (maxRow - 1) * 7;
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = self.frame.size.height / maxRow;
    
    CGRect frame = self.frame;
    frame.size.height -= itemHeight;
    _scrollview.frame = frame;
    
    NSInteger totalPage = [self.faces count]%pageSize == 0 ? [self.faces count]/pageSize : [self.faces count]/pageSize + 1;
    [_scrollview setContentSize:CGSizeMake(totalPage * CGRectGetWidth(self.frame), itemHeight * (maxRow - 1))];
    
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = totalPage;
    _pageControl.frame = CGRectMake(0, (maxRow - 1) * itemHeight + 5, CGRectGetWidth(self.frame), itemHeight - 10);
    
    for (int i = 0; i < totalPage; i ++) {
        for (int row = 0; row < (maxRow - 1); row++) {
            for (int col = 0; col < maxCol; col++) {
                NSInteger index = i * pageSize + row * maxCol + col;
                if (index != 0 && (index - (pageSize-1))%pageSize == 0) {
                    [self.faces insertObject:@"" atIndex:index];
                    break;
                }
                if (index < [self.faces count]) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button setFrame:CGRectMake(i * CGRectGetWidth(self.frame) + col * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                    [button setTitle: [self.faces objectAtIndex:index] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                    button.tag = index;
                    [_scrollview addSubview:button];
                }
                else{
                    break;
                }
            }
        }
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setBackgroundColor:[UIColor clearColor]];
        [deleteButton setFrame:CGRectMake(i * CGRectGetWidth(self.frame) + (maxCol - 1) * itemWidth, (maxRow - 2) * itemHeight, itemWidth, itemHeight)];
        [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateHighlighted];
        deleteButton.tag = 10000;
        [deleteButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollview addSubview:deleteButton];
    }
    

}


- (void)selected:(UIButton*)bt
{
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    } else{
        NSString *str = [self.faces objectAtIndex:bt.tag];
        if (_delegate) {
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)sendAction:(id)sender
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

- (void)sendPngAction:(UIButton*)bt
{
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    }else{
        NSString *str = [self.faces objectAtIndex:bt.tag];
        if (_delegate) {
            str = [NSString stringWithFormat:@"\\::%@]",str];
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)sendGifAction:(UIButton*)bt
{
    NSString *str = [self.faces objectAtIndex:bt.tag];
    if (_delegate) {
        [_delegate sendFace:str];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

#pragma mark getter and setter

- (UIScrollView *)scrollview {
    if (_scrollview == nil) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.pagingEnabled = YES;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.alwaysBounceHorizontal = YES;
        _scrollview.delegate = self;
    }
    return  _scrollview;
}


- (NSMutableArray *)faces {
    if (_faces == nil) {
        _faces = [NSMutableArray arrayWithArray:[AgoraEmoji allEmoji]];
    }
    return _faces;
}


- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
    }
    return _pageControl;
}

@end
