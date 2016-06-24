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
    
    self.title = NSLocalizedString(@"AppName", @"");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - Actions

// Register an IM account
- (IBAction)doRegister:(id)sender
{
    if (![self isInputsEmpty]) {
        
        [self.view endEditing:YES];
        
        [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[EMClient sharedClient] asyncRegisterWithUsername:self.usernameTextField.text password:self.passwordTextField.text success:^{
                
                // Update APNs display name
                [[EMClient sharedClient] asyncSetApnsNickname:self.usernameTextField.text success:^{
                    
                } failure:^(EMError *aError) {
                    TTAlertNoTitle(aError.errorDescription);
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self hideHud];
                    
                    [self showHudInView:self.view hint:NSLocalizedString(@"register.success", @"")];
                    
                    double delayInSeconds = 2.0;
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [self hideHud];

                        // Log in user
                        [self loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
                    });
                });
                
            } failure:^(EMError *aError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self hideHud];
                    
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
                });
            }];
        });
    }
}

- (IBAction)doLogin:(id)sender
{
    if (![self isInputsEmpty]) {
        
        [self.view endEditing:YES];
        
        [self loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    }
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [self showHudInView:self.view hint:NSLocalizedString(@"login.inProgress", @"")];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
        [[EMClient sharedClient] asyncLoginWithUsername:username password:password success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self hideHud];
                                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                [[ChatDemoHelper shareHelper] login];
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });

        } failure:^(EMError *aError) {
            
            [[ChatDemoHelper shareHelper] logout];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self hideHud];
                
                TTAlertNoTitle(aError.errorDescription);

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
                    case EMErrorUserNotFound:
                        TTAlertNoTitle(NSLocalizedString(@"error.login.userNotFound", @""));
                        break;
                    default:
                        TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                        break;
                }
            });
        }];
    });
}

- (BOOL)isInputsEmpty
{
    BOOL isEmptyField = NO;
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if (username.length == 0 || password.length == 0) {
        
        isEmptyField = YES;
        
        [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password")
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    
    return isEmptyField;
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
