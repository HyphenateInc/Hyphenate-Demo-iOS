/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraAccountViewController.h"
#import "AgoraModifyNickNameViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+HeadImage.h"
#import "UIViewController+HUD.h"


@interface AgoraAccountViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *signOutButton;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, copy) NSString *myName;

@property (nonatomic, strong) AgoraUserInfo *userInfo;

@end

@implementation AgoraAccountViewController

#pragma mark life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = PaleGrayColor;

    [self setupNavigationBar];
    [self placeAndLayoutSubviews];
    [self loadData];
}

- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.table];
    [self.view addSubview:self.signOutButton];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.signOutButton.mas_top).offset(-kAgroaPadding * 3.0);
    }];
    
    [self.signOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-kAgroaPadding * 3.0);
        make.left.equalTo(self.view).offset(kAgroaPadding * 3.0);
        make.right.equalTo(self.view).offset(-kAgroaPadding * 3.0);
        make.height.mas_equalTo(44.0);
    }];
}



- (void)setupNavigationBar
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Actions

- (void)loadData {
    [AgoraUserInfoManagerHelper fetchOwnUserInfoCompletion:^(AgoraUserInfo * _Nonnull ownUserInfo) {
            self.userInfo = ownUserInfo;
            self.myName = self.userInfo.nickName ?:self.userInfo.userId;

            if (self.userInfo.avatarUrl) {
                [self.avatarView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
            }else {
                [self.avatarView sd_setImageWithURL:nil placeholderImage:ImageWithName(@"default_avatar")];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
    }];
}


- (void)editAvatar {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)signOut
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WEAK_SELF
    [[AgoraChatClient sharedClient] logout:YES completion:^(AgoraError *aError) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!aError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        } else {
            [weakSelf showHint:[NSString stringWithFormat:@"%@:%u",NSLocalizedString(@"logout.failed", @"Logout failed"), aError.code]];
        }
    }];
}



#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AccountCell";
    AgoraChatCustomBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AgoraChatCustomBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
//    if (indexPath.row == 0) {
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [cell.contentView addSubview:self.avatarView];
////        [cell.contentView addSubview:self.editButton];
//    } else if (indexPath.row == 1) {
//
//        cell.textLabel.text = NSLocalizedString(@"setting.account.name", @"Name");
//        cell.detailTextLabel.text = _myName ?: [[AgoraChatClient sharedClient] currentUsername];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    } else {
//
//        cell.textLabel.text = NSLocalizedString(@"setting.account.id", @"Hyphenate ID");
//        cell.detailTextLabel.text = [[AgoraChatClient sharedClient] currentUsername];
//    }
    
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.avatarView];
//        [cell.contentView addSubview:self.editButton];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"setting.account.id", @"Hyphenate ID");
        cell.detailTextLabel.text = [[AgoraChatClient sharedClient] currentUsername];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 70;
    } else {
        return 45;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
//        [self editAvatar];
    } else if (indexPath.row == 1) {
//        AgoraModifyNickNameViewController *vc = [[AgoraModifyNickNameViewController alloc] init];
//        vc.title = NSLocalizedString(@"setting.account.name", @"Name");
//        vc.myNickName = _myName;
//        vc.callBack = ^(NSString *newName) {
//            _myName = newName;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            });
//        };
//        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.uploading", @"Uploading..")];
    WEAK_SELF
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (orgImage) {
//        [[AgoraUserProfileManager sharedInstance] uploadUserHeadImageProfileInBackground:orgImage completion:^(BOOL success, NSError *error) {
//            [weakSelf hideHud];
//            if (success) {
//
//                [weakSelf showHint:NSLocalizedString(@"setting.uploadSuccess", @"uploaded successfully")];
//                UserProfileEntity *user = [[AgoraUserProfileManager sharedInstance] getCurUserProfile];
//                [weakSelf.avatarView imageWithUsername:user.username placeholderImage:orgImage];
//            } else {
//                [weakSelf showHint:NSLocalizedString(@"setting.uploadFailed", @"Upload Failed")];
//            }
//        }];
        
        [self.avatarView imageWithUsername:nil placeholderImage:orgImage];
    } else {
        [self hideHud];
        [self showHint:NSLocalizedString(@"setting.uploadFailed", @"Upload Failed")];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark getter and setter
- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 45/2;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.frame = CGRectMake(15, 13, 45, 45);
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    }

    return _avatarView;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setTitle:NSLocalizedString(@"setting.account.edit", @"Edit")   forState:UIControlStateNormal];
        [_editButton setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
        _editButton.frame = CGRectMake(75, 29, 30, 13);
        _editButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _editButton.enabled = NO;
//        [_editButton addTarget:self action:@selector(editAvatar) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}


- (UIButton *)signOutButton
{
    if (_signOutButton == nil) {
        _signOutButton = [[UIButton alloc] init];
        [_signOutButton setFrame:CGRectMake(0, self.view.frame.size.height - 44 - 45, KScreenWidth, 45)];
        [_signOutButton setBackgroundColor:OrangeRedColor];
        [_signOutButton setTitle:NSLocalizedString(@"setting.account.signout", @"Sign out") forState:UIControlStateNormal];
        [_signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _signOutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];

    }
    return _signOutButton;
}

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

- (UITableView *)table {
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _table.separatorColor = CoolGrayColor50;
        _table.scrollEnabled = NO;
        _table.backgroundColor = PaleGrayColor;
        _table.delegate = self;
        _table.dataSource = self;
        _table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

    }
    return _table;
}


@end
