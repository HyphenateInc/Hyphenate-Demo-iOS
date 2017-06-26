/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMContactListSectionHeader.h"

#define KEM_CONTACTREQUESTS_TITLE            NSLocalizedString(@"contact.requests", @"Contact Requests")
#define KEM_GROUPNOTIFICATIONS_TITLE         NSLocalizedString(@"group.notifications", @"Group Notifications")

@interface EMContactListSectionHeader()

@property (strong, nonatomic) IBOutlet UIImageView *icon;

@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) IBOutlet UILabel *unhandledCount;

@end

@implementation EMContactListSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = DenimColor;
    _icon.image = [UIImage imageNamed:@"Icon_Invitations"];
    _title.text = KEM_GROUPNOTIFICATIONS_TITLE;
    _unhandledCount.text = @"";
}

- (void)updateInfo:(NSInteger)unhandleCount section:(NSInteger)section {
    switch (section) {
        case 0:
            _title.text = KEM_GROUPNOTIFICATIONS_TITLE;
            _icon.image = [UIImage imageNamed:@"Icon_Invitations.png"];
            break;
        case 1:
            _title.text = KEM_CONTACTREQUESTS_TITLE;
            _icon.image = [UIImage imageNamed:@"Icon_Requests.png"];
            break;
        default:
            _icon.hidden = _title.hidden = _unhandledCount.hidden = YES;
            self.backgroundColor = PaleGrayColor;
            _unhandledCount.hidden = YES;
            break;
    }
    _unhandledCount.text = [NSString stringWithFormat:@"(%d)",(int)unhandleCount];
}


@end
