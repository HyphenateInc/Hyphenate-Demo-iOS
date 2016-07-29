/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "GroupSubjectChangingViewController.h"

@interface GroupSubjectChangingViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *subjectField;

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, assign) BOOL isOwner;

@end

@implementation GroupSubjectChangingViewController

- (instancetype)initWithGroup:(EMGroup *)group
{
    self = [self init];
    
    if (self) {
        
        self.group = group;
        
        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
        self.isOwner = [self.group.owner isEqualToString:loginUsername];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"title.groupSubjectChanging", @"Change Group Name");

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    if (self.isOwner)
    {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", @"Save")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(save:)];
        saveItem.tintColor = [UIColor HIPrimaryColor];
        
        [self.navigationItem setRightBarButtonItem:saveItem];
    }

    CGRect frame = CGRectMake(20, 80, self.view.frame.size.width - 40, 40);
    self.subjectField = [[UITextField alloc] initWithFrame:frame];
    self.subjectField.layer.cornerRadius = 5.0;
    self.subjectField.layer.borderWidth = 1.0;
    self.subjectField.placeholder = NSLocalizedString(@"group.setting.subject", @"Please enter a group name");
    self.subjectField.text = self.group.subject;
  
    if (!self.isOwner) {
        self.subjectField.enabled = NO;
    }
    
    frame.origin = CGPointMake(frame.size.width - 5.0, 0.0);
    frame.size = CGSizeMake(5.0, 40.0);
    UIView *holder = [[UIView alloc] initWithFrame:frame];
    self.subjectField.rightView = holder;
    self.subjectField.rightViewMode = UITextFieldViewModeAlways;
    frame.origin = CGPointMake(0.0, 0.0);
    holder = [[UIView alloc] initWithFrame:frame];
    self.subjectField.leftView = holder;
    self.subjectField.leftViewMode = UITextFieldViewModeAlways;
    self.subjectField.delegate = self;
    [self.view addSubview:self.subjectField];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action

- (void)save:(id)sender
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:_group.groupId type:EMConversationTypeGroupChat createIfNotExist:NO];
    
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.saving", "saving...")];
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].groupManager updateGroupSubject:_subjectField.text forGroup:_group.groupId  completion:^(EMGroup *aGroup, EMError *aError) {
        GroupSubjectChangingViewController *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf hideHud];
            if (!aError) {
                if ([strongSelf.group.groupId isEqualToString:conversation.conversationId]) {
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:strongSelf.group.subject forKey:@"subject"];
                    [ext setObject:[NSNumber numberWithBool:strongSelf.group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                }
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
            else {
                [strongSelf showHint:NSLocalizedString(@"setting.saveFailed", "save failed")];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

@end
