/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraModifyNickNameViewController.h"
#import "AgoraUserProfileManager.h"

@interface AgoraModifyNickNameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameTextField;
@end

@implementation AgoraModifyNickNameViewController
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
 
}

#pragma private method
- (void)updateMyName:(NSString *)newName
{
    if (newName.length > 0 && ![_myNickName isEqualToString:newName])
    {
        _myNickName = newName;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:newName withType:AgoraUserInfoTypeNickName completion:^(AgoraUserInfo *aUserInfo, AgoraError *aError) {
                NSLog(@"%s updateOwnUserInfo aDisplayName:%@ aError:%@",__func__,aUserInfo.nickName,aError);
                
                if (aError) {

                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.callBack) {
                            self.callBack(newName);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }];
        });
    }
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateMyName:textField.text];
    return YES;
}


#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"NameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    self.nameTextField.frame = CGRectMake(15, 0, self.tableView.frame.size.width, cell.contentView.frame.size.height);
    [cell.contentView addSubview:self.nameTextField];
    
    return cell;
}

#pragma mark getter and setter
- (UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.textColor = AlmostBlackColor;
        _nameTextField.textAlignment = NSTextAlignmentLeft;
        _nameTextField.font = [UIFont systemFontOfSize:13];
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.text = _myNickName;
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}


@end
