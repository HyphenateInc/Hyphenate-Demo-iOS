//
//  AgoraUserInfoManager.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraUserInfoManagerHelper.h"

#define kExpireSeconds 60

@interface AgoraUserInfoManagerHelper ()
@property (nonatomic, strong)NSMutableDictionary *userInfoCacheDic;

@end


@implementation AgoraUserInfoManagerHelper
static AgoraUserInfoManagerHelper *instance = nil;
+ (AgoraUserInfoManagerHelper *)sharedAgoraUserInfoManagerHelper {
static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[AgoraUserInfoManagerHelper alloc]init];
    });
    return instance;
}

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedAgoraUserInfoManagerHelper] fetchUserInfoWithUserIds:userIds completion:completion];
}


+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedAgoraUserInfoManagerHelper] fetchUserInfoWithUserIds:userIds userInfoTypes:userInfoTypes completion:completion];
}


+ (void)updateUserInfo:(AgoraUserInfo *)userInfo completion:(void (^)(AgoraUserInfo * _Nonnull))completion {
    [[self sharedAgoraUserInfoManagerHelper] updateUserInfo:userInfo completion:completion];
}

+ (void)updateUserInfoWithUserId:(NSString *)userId withType:(AgoraUserInfoType)type completion:(void (^)(AgoraUserInfo * _Nonnull))completion {
    [[self sharedAgoraUserInfoManagerHelper] updateUserInfoWithUserId:userId withType:type completion:completion];
}


#pragma mark instance method
- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,AgoraUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {
            [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:reqIds completion:^(NSDictionary *aUserDatas, AgoraError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    AgoraUserInfo *user = aUserDatas[userKey];
                    user.expireTime = [[NSDate date] timeIntervalSince1970];
                    if (user) {
                        resultDic[userKey] = user;
                        self.userInfoCacheDic[userKey] = user;
                    }
                }
                if (resultDic && completion) {
                    completion(resultDic);
                }
            }];
        }
    }];

}

- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,AgoraUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {

            [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:userIds type:userInfoTypes completion:^(NSDictionary *aUserDatas, AgoraError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    AgoraUserInfo *user = aUserDatas[userKey];
                    user.expireTime = [[NSDate date] timeIntervalSince1970];
                    if (user) {
                        resultDic[userKey] = user;
                        self.userInfoCacheDic[userKey] = user;
                    }
                }
                if (resultDic && completion) {
                    completion(resultDic);
                }
            }];
            
        }
    }];
    
    
}

- (void)updateUserInfo:(AgoraUserInfo *)userInfo
                       completion:(void(^)(AgoraUserInfo *aUserInfo))completion {
    
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userInfo completion:^(AgoraUserInfo *aUserInfo, AgoraError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

- (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(AgoraUserInfoType)type
                      completion:(void(^)(AgoraUserInfo *aUserInfo))completion {
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userId withType:type completion:^(AgoraUserInfo *aUserInfo, AgoraError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

#pragma mark private method
- (void)splitUserIds:(NSArray *)userIds
          completion:(void(^)(NSMutableDictionary<NSString *,AgoraUserInfo *> *resultDic,NSMutableArray<NSString *> *reqIds))completion {
    
    NSMutableDictionary<NSString *,AgoraUserInfo *> *resultDic = NSMutableDictionary.new;
    NSMutableArray<NSString *> *reqIds = NSMutableArray.new;
    
    for (NSString *userId in userIds) {
        AgoraUserInfo *user = self.userInfoCacheDic[userId];
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970] - user.expireTime;
        if (delta > kExpireSeconds || !user) {
            [reqIds addObject:userId];
        }else {
            resultDic[userId] = user;
        }
    }
    if (completion) {
        completion(resultDic,reqIds);
    }
}


#pragma mark getter and setter
- (NSMutableDictionary *)userInfoCacheDic {
    if (_userInfoCacheDic == nil) {
        _userInfoCacheDic = NSMutableDictionary.new;
    }
    return _userInfoCacheDic;
}

@end

#undef kExpireSeconds

