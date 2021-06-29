/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatToolBar.h"

#import "AgoraChatRecordView.h"
#import "AgoraMessageTextView.h"
#import "AgoraConvertToCommonEmoticonsHelper.h"
#import "AgoraFaceView.h"

typedef enum : NSUInteger {
    AgoraChatToolStateNone,
    AgoraChatToolStateTextInput,
    AgoraChatToolStateFaceView,
    AgoraChatToolStateRecordView,
} AgoraChatToolState;

#define kDefaultToolBarHeight 91
#define kDefaultTextViewWidth KScreenWidth - 30.f
#define kChatBoolContentViewHeight 187.0
#define kSendButtonWidth 50.0

@interface AgoraChatToolBar () <UITextViewDelegate,AgoraChatRecordViewDelegate,AgoraFaceDelegate>

@property (nonatomic,strong) UIView *activityButtomView;
@property (nonatomic,strong)  AgoraMessageTextView *inputTextView;

@property (nonatomic,strong)  UIButton *cameraButton;
@property (nonatomic,strong)  UIButton *photoButton;
@property (nonatomic,strong)  UIButton *emojiButton;
@property (nonatomic,strong)  UIButton *recordButton;
@property (nonatomic,strong)  UIButton *locationButton;
@property (nonatomic,strong)  UIButton *fileButton;
@property (nonatomic,strong)  UIButton *sendButton;
@property (nonatomic,strong)  UIView *line;

@property (nonatomic,strong) AgoraChatRecordView *recordView;
@property (nonatomic,strong) AgoraFaceView *faceView;

@property (nonatomic,strong) NSMutableArray *moreItems;
@property (nonatomic,assign) AgoraChatToolState toolState;

- (void)cameraAction:(id)sender;
- (void)photoAction:(id)sender;
- (void)locationAction:(id)sender;
- (void)recordAction:(id)sender;
- (void)emojiAction:(id)sender;
- (void)sendAction:(id)sender;

@end

@implementation AgoraChatToolBar
#pragma mark life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
        
        self.toolState = AgoraChatToolStateNone;
        [self placeAndLayoutSubviews];

    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)placeAndLayoutSubviews {

    [self addSubview:self.line];
    [self addSubview:self.inputTextView];
    [self addSubview:self.sendButton];
    [self addSubview:self.cameraButton];
    [self addSubview:self.photoButton];
    [self addSubview:self.emojiButton];
    [self addSubview:self.recordButton];
    [self addSubview:self.locationButton];
    [self addSubview:self.faceView];
    [self addSubview:self.recordView];
    
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line.mas_bottom).offset(kAgroaPadding);
        make.left.equalTo(self).offset(kAgroaPadding * 1.5);
        make.right.equalTo(self.sendButton.mas_left).offset(-kAgroaPadding * 1.5);
        make.height.mas_equalTo(34.0);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.inputTextView);
        make.left.equalTo(self.mas_right);
        make.width.mas_equalTo(kSendButtonWidth);
        make.height.equalTo(self.inputTextView);
    }];
    
    
    CGFloat buttonWidth = (KScreenWidth - kAgroaPadding * 2)/5.0;
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputTextView.mas_bottom).offset(kAgroaPadding);
        make.left.mas_equalTo(self).offset(kAgroaPadding);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(22.0);
    }];
    
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraButton);
        make.left.equalTo(self.cameraButton.mas_right);
        make.size.equalTo(self.cameraButton);
    }];
    
    [self.emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraButton);
        make.left.equalTo(self.photoButton.mas_right);
        make.size.equalTo(self.cameraButton);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraButton);
        make.left.equalTo(self.emojiButton.mas_right);
        make.size.equalTo(self.cameraButton);
    }];
    
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraButton);
        make.left.equalTo(self.recordButton.mas_right);
        make.size.equalTo(self.cameraButton);
    }];
        
    [self.faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self);
    }];
    
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self);
    }];
    
    self.faceView.hidden = YES;
    self.recordView.hidden = YES;

}

#pragma mark - getter and setter
- (UIView *)line {
    if (_line == nil) {
        _line = UIView.new;
        _line.backgroundColor = CoolGrayColor;
    }
    return _line;
}

- (AgoraMessageTextView *)inputTextView {
    if (_inputTextView == nil) {
        _inputTextView = [[AgoraMessageTextView alloc] initWithFrame:CGRectZero];
        _inputTextView.layer.borderColor = TextViewBorderColor.CGColor;
        _inputTextView.layer.borderWidth = 0.5;
        _inputTextView.placeHolder = NSLocalizedString(@"chat.placeHolder", @"Send Message");
        _inputTextView.placeHolderTextColor = CoolGrayColor;
        _inputTextView.delegate = self;
    }
    return _inputTextView;
}

- (UIButton *)sendButton {
    if (_sendButton == nil) {
        _sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sendButton setTitle:@"send" forState:UIControlStateNormal];
        [_sendButton setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
        _sendButton.layer.cornerRadius = 5.0;
        [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.hidden = YES;
    }
    return _sendButton;
}

- (UIButton *)photoButton {
    if (_photoButton == nil) {
        _photoButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _photoButton.layer.cornerRadius = 5.0;
        [_photoButton setImage:[UIImage imageNamed:@"Icon_Image"] forState:UIControlStateNormal];
        [_photoButton setImage:[UIImage imageNamed:@"Icon_Image active"] forState:UIControlStateSelected];
        [_photoButton addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton *)cameraButton {
    if (_cameraButton == nil) {
        _cameraButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _cameraButton.layer.cornerRadius = 5.0;
        [_cameraButton setImage:[UIImage imageNamed:@"Icon_Camera"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"Icon_Camera active"] forState:UIControlStateSelected];
        [_cameraButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)emojiButton {
    if (_emojiButton == nil) {
        _emojiButton = UIButton.new;
        _emojiButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _emojiButton.layer.cornerRadius = 5.0;
        [_emojiButton setImage:[UIImage imageNamed:@"icon_emoji_disable"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"Icon_Emoji"] forState:UIControlStateSelected];
        [_emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (UIButton *)recordButton {
    if (_recordButton == nil) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _recordButton.layer.cornerRadius = 5.0;
        [_recordButton setImage:[UIImage imageNamed:@"Icon_Audio_disable"] forState:UIControlStateNormal];
        [_recordButton setImage:[UIImage imageNamed:@"Icon_Audio"] forState:UIControlStateSelected];
        [_recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (UIButton *)locationButton {
    if (_locationButton == nil) {
        _locationButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _locationButton.layer.cornerRadius = 5.0;
        [_locationButton setImage:[UIImage imageNamed:@"Icon_Location_disable"] forState:UIControlStateNormal];
        [_locationButton setImage:[UIImage imageNamed:@"Icon_Location"] forState:UIControlStateSelected];
        [_locationButton addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}


- (AgoraChatRecordView*)recordView
{
    if (_recordView == nil) {
        _recordView = (AgoraChatRecordView*)[[[NSBundle mainBundle]loadNibNamed:@"AgoraChatRecordView" owner:nil options:nil] firstObject];
        _recordView.delegate = self;
    }
    return _recordView;
}

- (AgoraFaceView*)faceView
{
    if (_faceView == nil) {
        _faceView = [[AgoraFaceView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 180)];
        [_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];        
    }
    return _faceView;
}

- (NSMutableArray*)moreItems
{
    if (_moreItems == nil) {
        _moreItems = [NSMutableArray arrayWithArray:@[self.cameraButton,self.photoButton,self.emojiButton,self.recordButton,self.locationButton]];
    }
    return _moreItems;
}



#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    for (UIButton *btn in self.moreItems) {
        btn.selected = NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{

    self.emojiButton.selected = self.recordButton.selected = NO;
    self.toolState = AgoraChatToolStateTextInput;

    [UIView animateWithDuration:0.25 animations:^{
        self.sendButton.hidden = NO;
        [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right).offset(-kAgroaPadding * 1.5 - kSendButtonWidth);
        }];
    }];
    
}
    

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.sendButton.hidden = YES;
        [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right);
        }];
    }];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView setNeedsDisplay];
}

#pragma mark - AgoraFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    NSString *chatText = self.inputTextView.text;
    
    if (!isDelete && str.length > 0) {
        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    } else {
        if (chatText.length >= 2) {
            NSString *subStr = [chatText substringFromIndex:chatText.length-2];
            if ([self.faceView stringIsFace:subStr]) {
                self.inputTextView.text = [chatText substringToIndex:chatText.length-2];
                [self textViewDidChange:self.inputTextView];
                return;
            }
        }
        if (chatText.length > 0) {
            self.inputTextView.text = [chatText substringToIndex:chatText.length-1];
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}

- (NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length
{
    NSRange range = [self.inputTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}

- (void)sendFace
{
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            if (![_inputTextView.text isEqualToString:@""]) {
                NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.inputTextView.attributedText.string];
                [self.delegate didSendText:attStr];
                self.inputTextView.text = @"";
            }
        }
    }
}

#pragma mark - AgoraChatRecordViewDelegate

- (void)didFinishRecord:(NSString *)recordPath duration:(NSInteger)duration
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendAudio:duration:)]) {
        [self.delegate didSendAudio:recordPath duration:duration];
    }
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillChange:(NSNotification *)aNoti {
    NSDictionary *userInfo = aNoti.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    if (CGRectEqualToRect(beginFrame, endFrame)) {
        return;
    }
    void(^animations)() = ^{
        [self _willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    [UIView animateWithDuration:duration delay:0.0f
                        options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState)
                     animations:animations completion:nil];
}

#pragma mark - action

- (void)cameraAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTakePhotos)]) {
        [self.delegate didTakePhotos];
    }
}

- (void)photoAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPhotos)]) {
        [self.delegate didSelectPhotos];
    }
}

- (void)emojiAction:(id)sender
{

    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    for (UIButton *btn in self.moreItems) {
        if (button != btn) {
            btn.selected = NO;
        }
    }
    
    if (button.selected) {
        self.toolState = AgoraChatToolStateFaceView;
        [self.inputTextView resignFirstResponder];
    } else {
        self.toolState = AgoraChatToolStateNone;
    }

    [self _willShowBottomView:self.faceView];
}

- (void)locationAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLocation)]) {
        [self.delegate didSelectLocation];
    }
}

- (void)recordAction:(id)sender
{
    self.toolState = AgoraChatToolStateRecordView;
    
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    for (UIButton *btn in self.moreItems) {
        if (button != btn) {
            btn.selected = NO;
        }
    }
    
    if (button.selected) {
        [self.inputTextView resignFirstResponder];
        self.toolState = AgoraChatToolStateRecordView;
    } else {
        self.toolState = AgoraChatToolStateNone;
    }

    [self _willShowBottomView:self.recordView];

}

- (void)sendAction:(id)sender
{
    if (_inputTextView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:[AgoraConvertToCommonEmoticonsHelper convertToCommonEmoticons:_inputTextView.text]];
        }
        _inputTextView.text = @"";
    }
}

#pragma mark - private method
- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    NSLog(@"begin %@ -- end %@", NSStringFromCGRect(beginFrame), NSStringFromCGRect(toFrame));
    if (beginFrame.origin.y == KScreenHeight) {
        [self _willShowBottomHeight:toFrame.size.height];

    } else if (toFrame.origin.y == KScreenHeight) {
        [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self.recordView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self _willShowBottomHeight:0];
        
    } else{
        [self _willShowBottomHeight:toFrame.size.height];
    }

}

- (void)_willShowBottomView:(UIView *)bottomView
{

    if (self.toolState == AgoraChatToolStateFaceView) {
        [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kChatBoolContentViewHeight);
        }];
        
        [self.recordView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        self.faceView.hidden = NO;
        self.recordView.hidden = YES;

        [self _willShowBottomHeight:kChatBoolContentViewHeight];

    }
    
    if (self.toolState == AgoraChatToolStateRecordView) {
        [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self.recordView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kChatBoolContentViewHeight);
        }];
        
        self.faceView.hidden = YES;
        self.recordView.hidden = NO;

        [self _willShowBottomHeight:kChatBoolContentViewHeight];

    }
    
    
    if (self.toolState == AgoraChatToolStateNone) {
        [self.faceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self.recordView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        self.faceView.hidden = self.recordView.hidden = YES;
        
        [self _willShowBottomHeight:0];
    }
    
}

- (void)_willShowBottomHeight:(CGFloat)bottomHeight
{
    [self _willShowViewFromHeight:bottomHeight];
}

- (void)_willShowViewFromHeight:(CGFloat)toHeight
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBarDidChangeFrameToHeight:)]) {
        [self.delegate chatToolBarDidChangeFrameToHeight:toHeight];
    }
}



//- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
//{
//    NSLog(@"begin %@ -- end %@", NSStringFromCGRect(beginFrame), NSStringFromCGRect(toFrame));
//    if (beginFrame.origin.y == KScreenHeight) {
//        [self _willShowBottomHeight:toFrame.size.height];
//        if (self.activityButtomView) {
//            [self.activityButtomView removeFromSuperview];
//        }
//        self.activityButtomView = nil;
//    } else if (toFrame.origin.y == KScreenHeight) {
//        [self _willShowBottomHeight:0];
//    } else{
//        [self _willShowBottomHeight:toFrame.size.height];
//    }
//}
//
//- (void)_willShowBottomView:(UIView *)bottomView
//{
//    if (![self.activityButtomView isEqual:bottomView]) {
//        CGFloat bottomHeight = bottomView ? bottomView.height : 0;
//        [self _willShowBottomHeight:bottomHeight];
//
//        if (bottomView) {
//            bottomView.top = kDefaultToolBarHeight;
//            [self addSubview:bottomView];
//        }
//        if (self.activityButtomView) {
//            [self.activityButtomView removeFromSuperview];
//        }
//        self.activityButtomView = bottomView;
//    }
//}
//
//- (void)_willShowBottomHeight:(CGFloat)bottomHeight
//{
//    [self _willShowViewFromHeight:bottomHeight];
//}
//
//- (void)_willShowViewFromHeight:(CGFloat)toHeight
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(chatToolBarDidChangeFrameToHeight:)]) {
//        [self.delegate chatToolBarDidChangeFrameToHeight:toHeight];
//    }
//}



@end

#undef kDefaultToolBarHeight
#undef kDefaultTextViewWidth
#undef kChatBoolContentViewHeight
#undef kSendButtonWidth
