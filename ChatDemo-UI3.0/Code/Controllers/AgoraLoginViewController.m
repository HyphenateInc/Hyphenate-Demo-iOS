/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraLoginViewController.h"

#import "UIViewController+DismissKeyboard.h"

#define kMaxLimitLength 64

@interface AgoraLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AgoraChatBaseTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upConstraint;
@property (nonatomic, assign) BOOL isRigisterState;

- (IBAction)doLogin:(id)sender;
- (IBAction)doSignUp:(id)sender;
- (IBAction)doChangeState:(id)sender;

@end

@implementation AgoraLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setBackgroundColor];
    [self setupForDismissKeyboard];
        
    _usernameTextField.delegate = self;
    _usernameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, _usernameTextField.height)];
    _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    _passwordTextField.delegate = self;
    _passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, _usernameTextField.height)];
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _loginButton.top = KScreenHeight - _loginButton.height;
    _loginButton.width = KScreenWidth;
    
    _signupButton.top = KScreenHeight - _loginButton.height;
    _signupButton.width = KScreenWidth;
    
    _usernameTextField.placeholder = NSLocalizedString(@"login.usernameTextField.hyphenateID", @"HyphenateID");
    _passwordTextField.placeholder = NSLocalizedString(@"login.passwordTextField.password", @"Password");
    [_loginButton setTitle:NSLocalizedString(@"login.loginButton.login", @"LOG IN") forState:UIControlStateNormal];
    [_signupButton setTitle:NSLocalizedString(@"login.signupButton.signup", @"SIGN UP") forState:UIControlStateNormal];
    
    [_usernameTextField adaptForDarkMode];
    [_passwordTextField adaptForDarkMode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)setBackgroundColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [UIScreen mainScreen].bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)LaunchTopColor.CGColor,(id)LaunchBottomColor.CGColor,nil];
    [gradient setStartPoint:CGPointMake(0.0, 0.0)];
    [gradient setEndPoint:CGPointMake(0.0, 1.0)];
    [self.view.layer insertSublayer:gradient atIndex:0];
}


#pragma mark - action

- (IBAction)doLogin:(id)sender
{
    if ([self _isEmpty]) {
        return;
    }
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient] loginWithUsername:_usernameTextField.text
                                      password:_passwordTextField.text
                                    completion:^(NSString *aUsername, AgoraChatError *aError) {
                                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                        if (!aError) {
                                            [[AgoraChatClient sharedClient].options setIsAutoLogin:YES];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                                        } else {
                                            NSString *alertStr = NSLocalizedString(@"login.failure", @"Login failure");
                                            switch (aError.code)
                                            {
                                                case AgoraChatErrorUserNotFound:
                                                    alertStr = aError.errorDescription;
                                                    break;
                                                case AgoraChatErrorNetworkUnavailable:
                                                    alertStr = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                                                    break;
                                                case AgoraChatErrorServerNotReachable:
                                                    alertStr = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                                                    break;
                                                case AgoraChatErrorUserAuthenticationFailed:
                                                    alertStr = NSLocalizedString(@"login.failure.password.notmatch", @"Password does not match username");
                                                    break;
                                                case AgoraChatErrorServerTimeout:
                                                    alertStr = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                                                    break;
                                                default:
                                                    alertStr = NSLocalizedString(@"login.failure", @"Login failure");
                                                    break;
                                            }
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
                                            [alert show];
                                        }
                                    }];
}

- (IBAction)doSignUp:(id)sender
{
    if ([self _isEmpty]) {
        return;
    }
    

    [self.view endEditing:YES];
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient] registerWithUsername:_usernameTextField.text
                                         password:_passwordTextField.text
                                       completion:^(NSString *aUsername, AgoraChatError *aError) {
                                           NSString *alertStr = nil;
                                           [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                                           if (!aError) {
                                               alertStr = NSLocalizedString(@"login.signup.succeed", @"Sign in succeed");
                                           } else {
                                               alertStr = NSLocalizedString(@"login.signup.failure", @"Sign up failure");
                                               switch (aError.code)
                                               {
                                                   case AgoraChatErrorServerNotReachable:
                                                       alertStr = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                                                       break;
                                                   case AgoraChatErrorNetworkUnavailable:
                                                       alertStr = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                                                       break;
                                                   case AgoraChatErrorServerTimeout:
                                                       alertStr = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                                                       break;
                                                   case AgoraChatErrorUserAlreadyExist:
                                                       alertStr = NSLocalizedString(@"login.taken", @"Username taken");
                                                       break;
                                                   default:
                                                       alertStr = NSLocalizedString(@"login.signup.failure", @"Sign up failure");
                                                       break;
                                               }
                                           }
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
                                           [alert show];
                                       }];
}

- (IBAction)doChangeState:(id)sender
{
    [self setEditing:YES];
    if (_signupButton.hidden == YES) {
        _loginButton.hidden = YES;
        _signupButton.hidden = NO;
        [_changeButton setTitle:NSLocalizedString(@"login.changebutton.login", @"Log in") forState:UIControlStateNormal];
        _tipLabel.text = NSLocalizedString(@"login.signup.tips", @"Have an account?");
        self.isRigisterState = YES;
    } else {
        _loginButton.hidden = NO;
        _signupButton.hidden = YES;
        [_changeButton setTitle:NSLocalizedString(@"login.changebutton.signup", @"Sign up") forState:UIControlStateNormal];
        _tipLabel.text = NSLocalizedString(@"login.tips", @"Yay! New to Hyphenate?");
        self.isRigisterState = NO;
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _usernameTextField) {
        _passwordTextField.text = @"";
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        if (_signupButton.hidden == YES) {
            [self doLogin:nil];
        } else {
            [self doSignUp:nil];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.isRigisterState) {
        if (_usernameTextField.isFirstResponder &&_usernameTextField.text.length >= kMaxLimitLength) {
            [WHToast showErrorWithMessage:NSLocalizedString(@"register.userName.outOfLimit", @"Username length out of limit, maximum 64 bytes") duration:1.0 finishHandler:nil];

        }
        
        if (_passwordTextField.isFirstResponder && _passwordTextField.text.length >= kMaxLimitLength) {
            [WHToast showErrorWithMessage:NSLocalizedString(@"register.password.outOfLimit", @"Password length out of limit, maximum 64 bytes") duration:1.0 finishHandler:nil];
        }
    }
    return YES;
}


#pragma mark - private

- (BOOL)_isEmpty
{
    BOOL ret = NO;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
        [alert show];

    }
    
    return ret;
}



#pragma mark - notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *beginValue = [userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect beginRect;
    [beginValue getValue:&beginRect];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect buttonFrame;
    CGFloat top = 0;
    if (_signupButton.hidden) {
        buttonFrame = _loginButton.frame;
    } else {
        buttonFrame = _signupButton.frame;
    }
    if (endRect.origin.y == self.view.frame.size.height) {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame);
    } else if(beginRect.origin.y == self.view.frame.size.height){
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect) + 100;
        top = -100;
    } else {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect) + 100;;
        top = -100;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [[UIApplication sharedApplication].keyWindow setTop:top];
        _loginButton.frame = buttonFrame;
        _signupButton.frame = buttonFrame;
    }];
}

@end
#undef kMaxLimitLength

