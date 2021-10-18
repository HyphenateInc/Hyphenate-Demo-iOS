/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "UIImageView+HeadImage.h"

@implementation UIImageView (HeadImage)

- (void)imageWithUsername:(NSString *)username placeholderImage:(UIImage*)placeholderImage
{
    if (placeholderImage == nil) {
        placeholderImage = [UIImage imageNamed:@"default_avatar"];
    }

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:@[username] completion:^(NSDictionary * _Nonnull userInfoDic) {
            AgoraChatUserInfo *userInfo = userInfoDic[username];
            if (userInfo.avatarUrl) {
                [self sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:placeholderImage];
            }else {
                [self sd_setImageWithURL:nil placeholderImage:placeholderImage];
            }
        }];
    });
}

@end
