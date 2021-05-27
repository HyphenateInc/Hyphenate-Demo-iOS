//
//  AgoraUserInfoManager.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraUserInfoManagerHelper.h"

@implementation AgoraUserInfoManagerHelper
+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:userIds completion:^(NSDictionary *aUserDatas, AgoraError *aError) {
        if (aUserDatas && completion) {
            completion(aUserDatas);
        }
    }];
}

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:userIds type:userInfoTypes completion:^(NSDictionary *aUserDatas, AgoraError *aError) {
        if (aUserDatas && completion) {
            completion(aUserDatas);
        }
    }];
}

+ (void)updateUserInfo:(AgoraUserInfo *)userInfo
                       completion:(void(^)(AgoraUserInfo *aUserInfo))completion {
    
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userInfo completion:^(AgoraUserInfo *aUserInfo, AgoraError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

+ (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(AgoraUserInfoType)type
                      completion:(void(^)(AgoraUserInfo *aUserInfo))completion {
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userId withType:type completion:^(AgoraUserInfo *aUserInfo, AgoraError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}


@end
