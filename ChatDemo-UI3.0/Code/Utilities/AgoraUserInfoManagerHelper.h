//
//  AgoraUserInfoManager.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraUserInfoManagerHelper : NSObject

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion;

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion;

+ (void)updateUserInfo:(AgoraUserInfo *)userInfo
            completion:(void(^)(AgoraUserInfo *aUserInfo))completion;


+ (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(AgoraUserInfoType)type
                      completion:(void(^)(AgoraUserInfo *aUserInfo))completion;
@end

NS_ASSUME_NONNULL_END
