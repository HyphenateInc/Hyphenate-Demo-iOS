/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraApplyManager.h"
#import "AgoraApplyModel.h"
static AgoraApplyManager *manager = nil;

@interface AgoraApplyManager(){
    NSUserDefaults *_userDefaults;
    NSMutableArray *_contactApplys;
    NSMutableArray *_groupApplys;
}


@end

@implementation AgoraApplyManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraApplyManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _contactApplys = [NSMutableArray array];
        _groupApplys = [NSMutableArray array];
        [self loadAllApplys];
    }
    return self;
}

- (NSString *)localContactApplysKey {
    NSString *loginHyphenateId = [AgoraChatClient sharedClient].currentUsername;
    if (loginHyphenateId.length == 0) {
        return nil;
    }
    NSString *key = [loginHyphenateId stringByAppendingString:@"_contactApplys"];
    return key;
}

- (NSString *)localGroupApplysKey {
    NSString *loginHyphenateId = [AgoraChatClient sharedClient].currentUsername;
    if (loginHyphenateId.length == 0) {
        return nil;
    }
    NSString *key = [loginHyphenateId stringByAppendingString:@"_groupApplys"];
    return key;
}


- (void)loadAllApplys {
    NSString *contactKey = [manager localContactApplysKey];
    if (contactKey.length > 0) {
        NSData *contactData = [_userDefaults objectForKey:contactKey];
        if (contactData.length > 0) {
            _contactApplys = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
        }
    }
    
    NSString *groupKey = [manager localGroupApplysKey];
    if (groupKey.length > 0) {
        NSData *groupData = [_userDefaults objectForKey:groupKey];
        if (groupData.length > 0) {
            _groupApplys = [NSKeyedUnarchiver unarchiveObjectWithData:groupData];
        }
    }
}


#pragma mark - public

- (NSUInteger)unHandleApplysCount {
    return _contactApplys.count + _groupApplys.count;
}

- (NSArray *)contactApplys {
    [_contactApplys removeAllObjects];
    NSString *contactKey = [manager localContactApplysKey];
    if (contactKey.length > 0) {
        NSData *contactData = [_userDefaults objectForKey:contactKey];
        if (contactData.length > 0) {
            _contactApplys = [NSKeyedUnarchiver unarchiveObjectWithData:contactData];
        }
    }
    return _contactApplys;
}

- (NSArray *)groupApplys {
    [_groupApplys removeAllObjects];
    NSString *groupKey = [manager localGroupApplysKey];
    if (groupKey.length > 0) {
        NSData *groupData = [_userDefaults objectForKey:groupKey];
        if (groupData.length > 0) {
            _groupApplys = [NSKeyedUnarchiver unarchiveObjectWithData:groupData];
        }
    }
    return _groupApplys;
}


- (BOOL)isExistingRequest:(NSString *)applyHyphenateId
                  groupId:(NSString *)groupId
               applyStyle:(AgoraApplyStyle)applyStyle {
    NSArray *sources = nil;
    __block BOOL isExistingRequest = NO;
    if (applyStyle == AgoraApplyStyle_contact) {
        sources = [self contactApplys];
    }
    else if (applyStyle != AgoraApplyStyle_contact) {
        if (!groupId || groupId.length == 0) {
            return YES;
        }
        sources = [self groupApplys];
    }
    if (sources.count > 0) {
        [sources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(IAgoraApplyModel)]) {
                id<IAgoraApplyModel> model = (id<IAgoraApplyModel>)obj;
                if ([model.applyHyphenateId isEqualToString:applyHyphenateId] && model.style == applyStyle)
                {
                    if (applyStyle == AgoraApplyStyle_contact ||
                        (applyStyle != AgoraApplyStyle_contact && [model.groupId isEqualToString:groupId]))
                    {
                        isExistingRequest = YES;
                        *stop = YES;
                    }
                }
            }
        }];
    }
    return isExistingRequest;
}

- (void)addApplyRequest:(AgoraApplyModel *)model {
    NSString *key = @"";
    NSArray *array = [NSArray array];
    if (model.style == AgoraApplyStyle_contact) {
        key = [manager localContactApplysKey];
        [_contactApplys addObject:model];
        array = _contactApplys;
    }
    else {
        key = [manager localGroupApplysKey];
        [_groupApplys addObject:model];
        array = _groupApplys;
    }
    if (key.length == 0) {
        return;
    }
    @synchronized (self) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [_userDefaults setObject:data forKey:key];
        [_userDefaults synchronize];
    }
}

- (void)removeApplyRequest:(AgoraApplyModel *)model {
    
    NSString *key = @"";
    NSMutableArray *array = [NSMutableArray array];
    if (model.style == AgoraApplyStyle_contact) {
        key = [manager localContactApplysKey];
        array = _contactApplys;
    }
    else {
        key = [manager localGroupApplysKey];
        array = _groupApplys;
    }
    if (key.length == 0) {
        return;
    }
    @synchronized (self) {
        __block NSInteger index = -1;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(IAgoraApplyModel)]) {
                id<IAgoraApplyModel> applyModel = (id<IAgoraApplyModel>)obj;
                if ([applyModel.recordId isEqualToString:model.recordId]) {
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        if (index >= 0) {
            [array removeObjectAtIndex:index];
        }
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [_userDefaults setObject:data forKey:key];
        [_userDefaults synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [manager loadAllApplys];
        });
    }
}

@end
