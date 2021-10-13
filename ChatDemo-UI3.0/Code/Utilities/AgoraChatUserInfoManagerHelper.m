//
//  AgoraChatUserInfoManagerHelper.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatUserInfoManagerHelper.h"

#define kExpireSeconds 60

@interface AgoraChatUserInfoManagerHelper ()
@property (nonatomic, strong)NSMutableDictionary *userInfoCacheDic;

@end


@implementation AgoraChatUserInfoManagerHelper
static AgoraChatUserInfoManagerHelper *instance = nil;
+ (AgoraChatUserInfoManagerHelper *)sharedAgoraChatUserInfoManagerHelper {
static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[AgoraChatUserInfoManagerHelper alloc]init];
    });
    return instance;
}

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedAgoraChatUserInfoManagerHelper] fetchUserInfoWithUserIds:userIds completion:completion];
}


+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedAgoraChatUserInfoManagerHelper] fetchUserInfoWithUserIds:userIds userInfoTypes:userInfoTypes completion:completion];
}


+ (void)updateUserInfo:(AgoraChatUserInfo *)userInfo completion:(void (^)(AgoraChatUserInfo * _Nonnull))completion {
    [[self sharedAgoraChatUserInfoManagerHelper] updateUserInfo:userInfo completion:completion];
}

+ (void)updateUserInfoWithUserId:(NSString *)userId withType:(AgoraChatUserInfoType)type completion:(void (^)(AgoraChatUserInfo * _Nonnull))completion {
    [[self sharedAgoraChatUserInfoManagerHelper] updateUserInfoWithUserId:userId withType:type completion:completion];
}

+ (void)fetchOwnUserInfoCompletion:(void(^)(AgoraChatUserInfo *ownUserInfo))completion {
    [[self sharedAgoraChatUserInfoManagerHelper] fetchOwnUserInfoCompletion:completion];
}

#pragma mark instance method
- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {
            [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:reqIds completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    AgoraChatUserInfo *user = aUserDatas[userKey];
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
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {

            [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:userIds type:userInfoTypes completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    AgoraChatUserInfo *user = aUserDatas[userKey];
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

- (void)updateUserInfo:(AgoraChatUserInfo *)userInfo
                       completion:(void(^)(AgoraChatUserInfo *aUserInfo))completion {
    
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userInfo completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

- (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(AgoraChatUserInfoType)type
                      completion:(void(^)(AgoraChatUserInfo *aUserInfo))completion {
    [[AgoraChatClient sharedClient].userInfoManager updateOwnUserInfo:userId withType:type completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

#pragma mark private method
- (void)splitUserIds:(NSArray *)userIds
          completion:(void(^)(NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic,NSMutableArray<NSString *> *reqIds))completion {
    
    NSMutableDictionary<NSString *,AgoraChatUserInfo *> *resultDic = NSMutableDictionary.new;
    NSMutableArray<NSString *> *reqIds = NSMutableArray.new;
    
    for (NSString *userId in userIds) {
        AgoraChatUserInfo *user = self.userInfoCacheDic[userId];
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


- (void)fetchOwnUserInfoCompletion:(void(^)(AgoraChatUserInfo *ownUserInfo))completion {
    NSString *userId = [AgoraChatClient sharedClient].currentUsername;
    [[AgoraChatClient sharedClient].userInfoManager fetchUserInfoById:@[userId] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
        AgoraChatUserInfo *user = aUserDatas[userId];
        if (completion) {
            completion(user);
        }
    }];
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

