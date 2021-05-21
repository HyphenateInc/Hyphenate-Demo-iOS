/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraCreateNewGroupViewController.h"
#import "AgoraUserModel.h"
#import "AgoraMemberCollectionCell.h"
#import "AgoraGroupPermissionCell.h"
#import "AgoraNotificationNames.h"
#import "AgoraMemberSelectViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+DismissKeyboard.h"

#define KAgora_GROUP_MAgoraBERSCOUNT         2000

@interface AgoraCreateNewGroupViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AgoraGroupUIProtocol>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIButton *groupAvatarSelectButton;
@property (strong, nonatomic) IBOutlet UITextField *groupSubjectTextField;
@property (strong, nonatomic) IBOutlet UILabel *memberCountLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *membersCollection;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic, strong) NSMutableArray<AgoraUserModel *> *occupants;

@end

@implementation AgoraCreateNewGroupViewController {
    UIButton *_createBtn;
    
    NSMutableArray<NSString *> *_invitees;
    NSMutableArray *_groupPermissions;
    BOOL _isPublic;
    BOOL _isAllowMemberInvite;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavbar];
    [self setupForDismissKeyboard];
    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = [UIView new];
    self.groupSubjectTextField.placeholder = NSLocalizedString(@"group.groupSubject", @"Group Subject");
    [self.membersCollection registerNib:[UINib nibWithNibName:@"AgoraMemberCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"AgoraMemberCollectionCell"];
    [self initBasicData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_groupSubjectTextField resignFirstResponder];
}

- (void)setupNavbar {
    self.title = NSLocalizedString(@"title.newGroup", @"New Group");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _createBtn.frame = CGRectMake(0, 0, 50, 40);
    _createBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_createBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [_createBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    [_createBtn setTitle:NSLocalizedString(@"group.create", @"Create") forState:UIControlStateNormal];
    [_createBtn setTitle:NSLocalizedString(@"group.create", @"Create") forState:UIControlStateHighlighted];
    [_createBtn addTarget:self action:@selector(createGroupAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:_createBtn];
    
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    rightSpace.width = -2;
    [self.navigationItem setRightBarButtonItems:@[rightSpace,rightBar]];
}

- (void)initBasicData {
    _invitees = [NSMutableArray array];
    _occupants = [NSMutableArray array];
    AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:[AgoraChatClient sharedClient].currentUsername];
    if (model) {
        [_occupants addObject:model];
    }
    [self reloadPermissions];
    [self updateMemberCountDescription];
}

- (void)reloadPermissions {
    _groupPermissions = [NSMutableArray array];
    AgoraGroupPermissionModel *model = [[AgoraGroupPermissionModel alloc] init];
    model.title = NSLocalizedString(@"group.isPublic", @"Appear in group search");
    model.isEdit = YES;
    model.switchState = NO;
    model.type = AgoraGroupInfoType_groupType;
    [_groupPermissions addObject:model];
    
    model = [[AgoraGroupPermissionModel alloc] init];
    model.title = NSLocalizedString(@"group.allowedOccupantInvite", @"Allow members to invite");
    model.isEdit = YES;
    model.switchState = NO;
    model.type = AgoraGroupInfoType_canAllInvite;
    [_groupPermissions addObject:model];
}

- (void)updatePermission {
    AgoraGroupPermissionModel *model = _groupPermissions.firstObject;
    model.switchState = _isPublic;
    [_groupPermissions replaceObjectAtIndex:0 withObject:model];
    
    model = _groupPermissions.lastObject;
    if (_isPublic) {
        model.title = NSLocalizedString(@"group.openJoin", @"Join the group freely");
        model.type = AgoraGroupInfoType_openJoin;
    }
    else {
        model.title = NSLocalizedString(@"group.allowedOccupantInvite", @"Allow members to invite");
        model.type = AgoraGroupInfoType_canAllInvite;
    }
    [_groupPermissions replaceObjectAtIndex:1 withObject:model];
    [self.tableView reloadData];
}

- (void)updateMemberCountDescription {
    _memberCountLabel.text = [NSString stringWithFormat:@"%@: %ld/%d",NSLocalizedString(@"group.participants", @"Participants"),(unsigned long)_occupants.count,KAgora_GROUP_MAgoraBERSCOUNT];
}

#pragma mark - Lazy Method

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setGroupAvatar:(id)sender {
    [_groupSubjectTextField resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"common.cancel", @"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"common.cameraPhoto", @"Take Photo"),NSLocalizedString(@"common.localPhoto", @"Choose Photo"), nil];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}


- (void)createGroupAction {
    if (_groupSubjectTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"message.inputGroupSubject", @"Please input a group theme")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK")
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    AgoraGroupOptions *options = [[AgoraGroupOptions alloc] init];
    options.maxUsersCount = KAgora_GROUP_MAgoraBERSCOUNT;
    if (_isPublic) {
        options.style = _isAllowMemberInvite ? AgoraGroupStylePublicOpenJoin : AgoraGroupStylePublicJoinNeedApproval;
    }
    else {
        options.style = _isAllowMemberInvite ? AgoraGroupStylePrivateMemberCanInvite : AgoraGroupStylePrivateOnlyOwnerInvite;
    }
    
    NSString *descreiption = [NSString stringWithFormat:NSLocalizedString(@"group.creategroup", @"%@ create a group[%@]"),[AgoraChatClient sharedClient].currentUsername, _groupSubjectTextField.text];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.inviteToJoin", @"%@ invite you to join the group [%@]"),[AgoraChatClient sharedClient].currentUsername, _groupSubjectTextField.text];
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _createBtn.userInteractionEnabled = NO;
    [[AgoraChatClient sharedClient].groupManager createGroupWithSubject:_groupSubjectTextField.text
                                                     description:descreiption
                                                        invitees:_invitees
                                                         message:message
                                                         setting:options
                                                      completion:^(AgoraGroup *aGroup, AgoraError *aError) {
                                                          [MBProgressHUD hideAllHUDsForView:weakSelf.navigationController.view animated:YES];
                                                          _createBtn.userInteractionEnabled = YES;
                                                          if (!aError) {
                                                              dispatch_async(dispatch_get_main_queue(), ^(){
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION
                                                                                                                      object:nil];
                                                                  [weakSelf.navigationController popViewControllerAnimated:YES];
                                                              });
                                                          }
                                                          else {
                                                              [weakSelf showAlertWithMessage:NSLocalizedString(@"group.createFailure", @"Create group failure")];
                                                          }
                                                      }
     ];
}

- (void)permissionSelectAction:(UISwitch *)permissionSwitch {
    if (permissionSwitch.tag == AgoraGroupInfoType_groupType) {
        _isPublic = permissionSwitch.isOn;
        [self updatePermission];
    }
    else {
        _isAllowMemberInvite = permissionSwitch.isOn;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AgoraGroupPermissionCell";
    AgoraGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupPermissionCell" owner:self options:nil] lastObject];
    }
    cell.model = _groupPermissions[indexPath.row];
    cell.permissionSwitch.tag = cell.model.type;
    [cell.permissionSwitch addTarget:self
                              action:@selector(permissionSelectAction:)
                    forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = tableView.backgroundColor;
    return view;
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _occupants.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AgoraMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AgoraMemberCollectionCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.model = nil;
    }
    else {
        cell.model = _occupants[indexPath.row];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        AgoraMemberSelectViewController *selectVc = [[AgoraMemberSelectViewController alloc] initWithInvitees:_invitees maxInviteCount:0];
        selectVc.style = AgoraContactSelectStyle_Add;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectVc];
        selectVc.title = NSLocalizedString(@"title.addParticipants", @"Add Participants");
        selectVc.delegate = self;
        [self presentViewController:nav animated:YES completion:nil];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

// Adjust item size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 5, collectionView.frame.size.height);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
#if TARGET_IPHONE_SIMULATOR
       
#elif TARGET_OS_IPHONE
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
        } else {
            
        }
#endif
    } else if (buttonIndex == 1) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (orgImage) {
        [_groupAvatarSelectButton setImage:orgImage forState:UIControlStateNormal];
        [_groupAvatarSelectButton setImage:orgImage forState:UIControlStateHighlighted];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AgoraGroupUIProtocol

- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    
    [self.occupants addObjectsFromArray:modelArray];
    [self.membersCollection reloadSections:[NSIndexSet indexSetWithIndex:1]];
    for (AgoraUserModel *model in modelArray) {
        [_invitees addObject:model.hyphenateId];
    }
}

@end
