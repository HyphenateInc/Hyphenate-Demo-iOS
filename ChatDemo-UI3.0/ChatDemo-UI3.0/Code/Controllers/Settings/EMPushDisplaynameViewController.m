/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMPushDisplaynameViewController.h"

@interface EMPushDisplaynameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *displayTextField;
@end

@implementation EMPushDisplaynameViewController



- (UITextField *)displayTextField
{
    if (!_displayTextField) {
        _displayTextField = [[UITextField alloc] init];
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

- (void)getUpdatedDisplayName:(UpdatedDisplayName)callBack
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
    
        [[EMClient sharedClient] updatePushNotifiationDisplayName:_currentDisplayName completion:^(NSString *aDisplayName, EMError *aError) {}];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    self.displayTextField.frame = CGRectMake(15, 0, self.tableView.frame.size.width, cell.contentView.frame.size.height);
    [cell.contentView addSubview:self.displayTextField];
    
    return cell;
}




@end
