/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraPushDisplaynameViewController.h"

@interface AgoraPushDisplaynameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) AgoraChatBaseTextField *displayTextField;
@end

@implementation AgoraPushDisplaynameViewController



- (AgoraChatBaseTextField *)displayTextField
{
    if (!_displayTextField) {
        _displayTextField = [[AgoraChatBaseTextField alloc] init];
        _displayTextField.textColor = AlmostBlackColor;
        _displayTextField.textAlignment = NSTextAlignmentLeft;
        _displayTextField.font = [UIFont systemFontOfSize:13];
        _displayTextField.borderStyle = UITextBorderStyleNone;
        _displayTextField.text = _currentDisplayName;
        _displayTextField.returnKeyType = UIReturnKeyDone;
        _displayTextField.delegate = self;
    }
    return _displayTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

}

- (void)getUpdatedDisplayName:(UpdatedDisplayNameBlock)callBack
{
    self.callBack = callBack;
}

- (void)back
{
    [self updatePushDisplayName:self.displayTextField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updatePushDisplayName:textField.text];
    return YES;
}

- (void)updatePushDisplayName:(NSString *)newDisplay
{
    if (![_currentDisplayName isEqualToString:newDisplay])
    {
        _currentDisplayName = newDisplay;
    
        [[AgoraChatClient sharedClient] updatePushNotifiationDisplayName:_currentDisplayName completion:^(NSString *aDisplayName, AgoraChatError *aError) {}];
        if (self.callBack) {
            self.callBack(_currentDisplayName);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"PushDisplayCell";
    AgoraChatCustomBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[AgoraChatCustomBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    self.displayTextField.frame = CGRectMake(15, 0, self.tableView.frame.size.width, cell.contentView.frame.size.height);
    [cell.contentView addSubview:self.displayTextField];
    
    return cell;
}




@end
