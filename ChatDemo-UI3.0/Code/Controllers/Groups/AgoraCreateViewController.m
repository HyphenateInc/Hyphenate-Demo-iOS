//
//  AgoraCreateViewNewController.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraCreateViewController.h"
#import "AgoraCreateNewGroupViewController.h"
#import "AgoraRealtimeSearchUtils.h"
#import "AgoraPublicGroupsViewController.h"

#define kLabelTextColor [UIColor colorWithRed:56.0/255.0 green:82.0/255.0 blue:109.0/255.0 alpha:1.0]

@interface AgoraCreateViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) UIButton *newGroupButton;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) AgoraPublicGroupsViewController *publicGroupsVC;

@end

@implementation AgoraCreateViewController
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = NSLocalizedString(@"title.create", @"Create");
    [self setupNavBar];
    [self placeAndLayoutSubviews];
}

- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.newGroupButton];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.searchBar];
    
    [self.newGroupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(50.0);
    }];
    
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.newGroupButton.mas_bottom);
        make.left.equalTo(self.view).offset(kAgroaPadding * 2);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(16.0);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.promptLabel);
        make.left.equalTo(self.promptLabel.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.view).offset(-kAgroaPadding);
        make.height.mas_equalTo(30.0);
    }];
    
    
    [self addChildViewController:self.publicGroupsVC];
    [self.view addSubview:self.publicGroupsVC.tableView];
    [self.publicGroupsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupNavBar {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 44, 44);
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
}

- (void)updateSearchBarFrame:(BOOL)isPromptHiden {

    if (isPromptHiden) {
        [self.promptLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(-kAgroaPadding);
            make.width.mas_equalTo(0);
        }];
    }else {
        [self.promptLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kAgroaPadding * 2);
            make.width.mas_equalTo(85);
        }];
    }
    
}


#pragma mark - Action Method
- (void)cancelAction {
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNewGroup {
    if (_searchBar.isFirstResponder) {
        [self searchBarCancelButtonClicked:_searchBar];
    }
    AgoraCreateNewGroupViewController *createVc = [[AgoraCreateNewGroupViewController alloc] initWithNibName:@"AgoraCreateNewGroupViewController"
                                                                                                bundle:nil];
    [self.navigationController pushViewController:createVc animated:YES];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self updateSearchBarFrame:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.publicGroupsVC setSearchState:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        [self.publicGroupsVC setSearchResultArray:@[] isEmptySearchKey:YES];
        return;
    }
    
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:self.publicGroupsVC.publicGroups searchString:searchText resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.publicGroupsVC setSearchResultArray:results isEmptySearchKey:NO];
        });
    }];
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [self updateSearchBarFrame:NO];
//    [searchBar setShowsCancelButton:NO animated:NO];
//    [searchBar resignFirstResponder];
//    self.publicGroupsVc.tableView.scrollEnabled = YES;
//
//    if (self.publicGroupsVc.searchResults.count > 0) {
//
//        return;
//    }
//    __weak typeof(self.publicGroupsVc) weakVc = self.publicGroupsVc;
//    WEAK_SELF
//    [[AgoraChatClient sharedClient].groupManager searchPublicGroupWithId:searchBar.text completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
//
//        AgoraPublicGroupsViewController *strongVc = weakVc;
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            if (aGroup) {
//                [strongVc.searchResults removeAllObjects];
//                AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:aGroup];
//                [strongVc.searchResults addObject:model];
//                [strongVc.tableView reloadData];
//            } else {
//                [weakSelf showAlertWithMessage:NSLocalizedString(@"common.searchFailure", @"Search failure.")];
//            }
//        });
//    }];
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self updateSearchBarFrame:NO];
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    [self.publicGroupsVC setSearchState:NO];
    [self.publicGroupsVC.tableView reloadData];
}

#pragma mark getter and setter
- (AgoraPublicGroupsViewController *)publicGroupsVC {
    if (_publicGroupsVC == nil) {
        _publicGroupsVC = [[AgoraPublicGroupsViewController alloc] init];
    }
    return _publicGroupsVC;
}


- (UIButton *)newGroupButton {
    if (_newGroupButton == nil) {
        _newGroupButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _newGroupButton.layer.cornerRadius = 5.0;
        [_newGroupButton setImage:ImageWithName(@"feedback") forState:UIControlStateNormal];
        [_newGroupButton setImage:ImageWithName(@"feedback") forState:UIControlStateSelected];
        [_newGroupButton setTitle:NSLocalizedString(@"group.new.NewGroup", @"New Group") forState:UIControlStateNormal];
        [_newGroupButton setTitle:NSLocalizedString(@"group.new.NewGroup", @"New Group") forState:UIControlStateSelected];
        [_newGroupButton setTitleColor:kLabelTextColor forState:UIControlStateNormal];
        [_newGroupButton setTitleColor:kLabelTextColor forState:UIControlStateSelected];

        [_newGroupButton addTarget:self action:@selector(createNewGroup) forControlEvents:UIControlEventTouchUpInside];
        [_newGroupButton setImageEdgeInsets:UIEdgeInsetsMake(0, -220.0, 0, 0)];
        [_newGroupButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -210.0, 0, 0)];

    }
    return _newGroupButton;
}


- (UILabel *)promptLabel {
    if (_promptLabel == nil) {
        _promptLabel = UILabel.new;
        _promptLabel.textAlignment = NSTextAlignmentLeft;
        _promptLabel.font = [UIFont systemFontOfSize:13.0f];
        _promptLabel.textColor = kLabelTextColor;
        _promptLabel.text = NSLocalizedString(@"group.new.publicGroups", @"Public Groups");
    }
    return _promptLabel;
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _searchBar.placeholder = NSLocalizedString(@"common.search", @"Search");
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:PaleGrayColor size:_searchBar.bounds.size] forState:UIControlStateNormal];
        _searchBar.tintColor = AlmostBlackColor;
        
    }
    return  _searchBar;
}

@end

#undef kLabelTextColor


