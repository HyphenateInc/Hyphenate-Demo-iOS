/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraContactInfoViewController.h"
#import "UIImage+ImageEffect.h"
#import "AgoraUserModel.h"
#import "AgoraContactInfoCell.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraChatViewController.h"

#define NAME                NSLocalizedString(@"contact.name", @"Name")
#define HYPHENATE_ID        NSLocalizedString(@"contact.hyphenateId", @"Hyphenate ID")
#define APNS_NICKNAME       NSLocalizedString(@"contact.apnsnickname", @"iOS APNS")
#define DELETE_CONTACT      NSLocalizedString(@"contact.delete", @"Delete Contact")
#define ADD_BLACKLIST       NSLocalizedString(@"contact.block", @"Black Contact")

#define KContactInfoKey     @"contactInfoKey"
#define KContactInfoValue   @"contactInfoValue"
#define KContactInfoTitle   @"contactInfoTitle"

typedef enum : NSUInteger {
    AgoraContactInfoActionNone,
    AgoraContactInfoActionDelete,
    AgoraContactInfoActionBlackList,
} AgoraContactInfoAction;

@interface AgoraContactInfoViewController ()<UIActionSheetDelegate, AgoraContactsUIProtocol>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (strong, nonatomic) AgoraUserModel *model;
@property (nonatomic,assign) AgoraContactInfoAction currentAction;

@end

@implementation AgoraContactInfoViewController
{
    NSArray *_contactInfo;
    NSArray *_contactActions;
}

- (instancetype)initWithUserModel:(AgoraUserModel *)model {
    self = [super initWithNibName:@"AgoraContactInfoViewController" bundle:nil];
    if (self) {
        _model = model;
        self.currentAction = AgoraContactInfoActionNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = [UIView new];
  
    [self loadContactInfo];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)loadContactInfo {
    _nickNameLabel.text = _model.nickname;
    _avatarImage.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [_avatarImage sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    
    [self buildData];
}

- (void)buildData {
    NSMutableArray *info = [NSMutableArray array];
    [info addObjectsFromArray:@[@{NAME:_model.nickname}, @{HYPHENATE_ID:_model.hyphenateId}]];
    if ([_model.hyphenateId isEqualToString:[AgoraChatClient sharedClient].currentUsername]) {
        NSString *displayName = [AgoraChatClient sharedClient].currentUsername;
        if (displayName.length > 0) {
            [info addObject:@{APNS_NICKNAME:displayName}];
        }
    }
    _contactInfo = [NSArray arrayWithArray:info];
//    _contactFunc = @[@{DELETE_CONTACT:RGBACOLOR(255.0, 59.0, 48.0, 1.0)}];
    _contactActions = @[@{_contactInfo:@(AgoraContactInfoTypeDelete),KContactInfoTitle:DELETE_CONTACT},@{KContactInfoKey:@(AgoraContactInfoTypeAddBlacklist),KContactInfoTitle:ADD_BLACKLIST}];
}

//- (void)makeCallWithContact:(NSString *)contact callTyfpe:(AgoraCallType)callType {
//    if (contact.length == 0) {
//        return;
//    }
//    if (callType == AgoraCallTypeVoice) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":contact, @"type":[NSNumber numberWithInt:0]}];
//    }
//    else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":contact, @"type":[NSNumber numberWithInt:1]}];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)chatAction:(id)sender {
    AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:_model.hyphenateId conversationType:AgoraChatConversationTypeChat];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (IBAction)callVoiceAction:(id)sender {
//    [self makeCallWithContact:_model.hyphenateId callTyfpe:AgoraCallTypeVoice];
}

- (IBAction)callVideoAction:(id)sender {
//    [self makeCallWithContact:_model.hyphenateId callTyfpe:AgoraCallTypeVideo];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        [scrollView setContentOffset:contentOffset];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _contactInfo.count;
    }
    return _contactActions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraContactInfoCell *cell = nil;
    if (indexPath.section == 0) {
        NSString *cellIdentify = @"AgoraContact_Info_Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraContactInfoCell" owner:self options:nil] lastObject];
        }
        cell.infoDic = _contactInfo[indexPath.row];
    }
    else {
        NSString *cellIdentify = @"AgoraContact_Info_func_Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraContactInfo_funcCell" owner:self options:nil] lastObject];
        }
        
        cell.hyphenateId = _model.hyphenateId;
        cell.infoDic = _contactActions[indexPath.row];
        cell.delegate = self;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            self.currentAction = AgoraContactInfoTypeDelete;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"common.cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"common.delete", @"Delete") otherButtonTitles:nil, nil];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        }
        
        if (indexPath.row == 1) {
            self.currentAction = AgoraContactInfoTypeAddBlacklist;
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"common.cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"common.addblackList", @"Add BlackList") otherButtonTitles:nil, nil];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    UIView *sectionHeader = [[UIView alloc] init];
    sectionHeader.backgroundColor = tableView.backgroundColor;
    return sectionHeader;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (self.currentAction == AgoraContactInfoTypeDelete) {
            [self deleteContact];
        }
        
        if (self.currentAction == AgoraContactInfoActionBlackList) {
            [self addBlackList];
        }
    }
}

- (void)deleteContact {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient].contactManager deleteContact:_model.hyphenateId isDeleteConversation:YES completion:^(NSString *aUsername, AgoraChatError *aError) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!aError) {
            if (self.deleteContactBlock) {
                self.deleteContactBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.deleteFailure", @"Delete contacts failed")];
        }
    }];
}

- (void)addBlackList {
    [[AgoraChatClient sharedClient].contactManager addUserToBlackList:_model.hyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
        if ((!aError)) {
            if (self.addBlackListBlock) {
                self.addBlackListBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.blockFailure", @"Black failure")];
        }
    }];
    
}

#pragma mark - AgoraContactsUIProtocol
- (void)needRefreshContactsFromServer:(BOOL)isNeedRefresh {
    if (isNeedRefresh) {
        [[AgoraChatDemoHelper shareHelper].contactsVC loadContactsFromServer];
    }
    else {
        [[AgoraChatDemoHelper shareHelper].contactsVC reloadContacts];
    }
}

@end


#undef NAME
#undef HYPHENATE_ID
#undef DELETE_CONTACT
#undef ADD_BLACKLIST
#undef KContactInfoKey
#undef KContactInfoValue
#undef KContactInfoTitle




