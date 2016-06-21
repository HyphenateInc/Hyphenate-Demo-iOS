/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 
 */

#import "LoginViewController.h"
#import "EMError.h"
#import "ChatDemoHelper.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)doRegister:(id)sender;
- (IBAction)doLogin:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupForDismissKeyboard];
    
    self.title = NSLocalizedString(@"AppName", @"Hyphenate Demo");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:NSStringFromClass(self.class) value:@""];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

// Register an IM account
- (IBAction)doRegister:(id)sender
{
    if (![self isEmpty]) {
        
        [self.view endEditing:YES];
        
        if ([self.usernameTextField.text isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
        
        [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
        
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient] asyncRegisterWithUsername:weakself.usernameTextField.text password:weakself.passwordTextField.text success:^{
            [weakself hideHud];
            
            [weakself showHudInView:weakself.view hint:NSLocalizedString(@"register.success", @"Is to register...")];
            
            double delayInSeconds = 2.0;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakself hideHud];
                //code to be executed on the main queue after delay
                [weakself loginWithUsername:weakself.usernameTextField.text password:weakself.passwordTextField.text];
            });
            
        } failure:^(EMError *aError) {
            [weakself hideHud];
            
            switch (aError.code) {
                case EMErrorServerNotReachable:
                    TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                    break;
                case EMErrorUserAlreadyExist:
                    TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
                    break;
                case EMErrorNetworkUnavailable:
                    TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                    break;
                case EMErrorServerTimeout:
                    TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                    break;
                default:
                    TTAlertNoTitle(NSLocalizedString(@"register.fail", @"Registration failed"));
                    break;
            }
        }];
    }
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [self showHudInView:self.view hint:NSLocalizedString(@"login.inProgress", @"")];
    
    __weak typeof(self) weakself = self;
    
    [[EMClient sharedClient] asyncLoginWithUsername:username password:password success:^{
        [weakself hideHud];
        
        [[EMClient sharedClient].options setIsAutoLogin:YES];
        
        [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        
        [[ChatDemoHelper shareHelper] asyncGroupFromServer];
        [[ChatDemoHelper shareHelper] asyncConversationFromDB];
        [[ChatDemoHelper shareHelper] asyncPushOptions];
        [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
        
    } failure:^(EMError *aError) {
        [weakself hideHud];
        
        switch (aError.code)
        {
            case EMErrorNetworkUnavailable:
                TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                break;
            case EMErrorServerNotReachable:
                TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                break;
            case EMErrorUserAuthenticationFailed:
                TTAlertNoTitle(aError.errorDescription);
                break;
            case EMErrorServerTimeout:
                TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                break;
            default:
                TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                break;
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        
        if(nameTextField.text.length > 0) {
            [[EMClient sharedClient] asyncSetApnsNickname:nameTextField.text success:^{
                
            } failure:^(EMError *aError) {
                
            }];
        }
    }
    
    [self loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
}

- (IBAction)doLogin:(id)sender
{
    if (![self isEmpty]) {
        
        [self.view endEditing:YES];
        
        if ([self.usernameTextField.text isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
        
        [self loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    }
}

- (BOOL)isEmpty
{
    BOOL ret = NO;
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (username.length == 0 || password.length == 0) {
        
        ret = YES;
        
        [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password")
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    
    return ret;
}


#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        self.passwordTextField.text = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self doLogin:nil];
    }
    
    return YES;
}

@end
