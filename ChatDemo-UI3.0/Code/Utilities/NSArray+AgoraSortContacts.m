/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "NSArray+AgoraSortContacts.h"
#import "AgoraUserModel.h"

@implementation NSArray (SortContacts)

+ (NSArray<NSArray *> *)sortContacts:(NSArray *)contacts
                       sectionTitles:(NSArray **)sectionTitles
                        searchSource:(NSArray **)searchSource {
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *_sectionTitles = [NSMutableArray arrayWithArray:indexCollation.sectionTitles];
    NSMutableArray *_contacts = [NSMutableArray arrayWithCapacity:_sectionTitles.count];
    for (int i = 0; i < _sectionTitles.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [_contacts addObject:array];
    }
    
    NSMutableArray *sortArray = NSMutableArray.new;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSMutableArray *userInfos = NSMutableArray.new;
    [AgoraUserInfoManagerHelper fetchUserInfoWithUserIds:contacts completion:^(NSDictionary * _Nonnull userInfoDic) {
        for (int i = 0; i< contacts.count; ++i) {
            AgoraUserInfo *userInfo = userInfoDic[contacts[i]];
            if (userInfo) {
                [userInfos addObject:userInfo];
            }
        }
    
        [userInfos sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            AgoraUserInfo *usr1 = (AgoraUserInfo *)obj1;
            AgoraUserInfo *usr2 = (AgoraUserInfo *)obj2;

            return [usr1.nickName caseInsensitiveCompare:usr2.nickName];
        }];
        
        for (int k = 0; k < userInfos.count; ++k) {
            AgoraUserInfo *userInfo = userInfos[k];
            if (userInfo) {
                [sortArray addObject:userInfo.userId];
            }
        }
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    

    NSMutableArray *_searchSource = [NSMutableArray array];
    for (NSString *hyphenateId in sortArray) {
        AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:hyphenateId];
        if (model) {
            NSString *firstLetter = [model.nickname substringToIndex:1];
            NSUInteger sectionIndex = [indexCollation sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
            NSMutableArray *array = _contacts[sectionIndex];
            [array addObject:model];
            [_searchSource addObject:model];
        }
    }

    __block NSMutableIndexSet *indexSet = nil;
    [_contacts enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            if (!indexSet) {
                indexSet = [NSMutableIndexSet indexSet];
            }
            [indexSet addIndex:idx];
        }
    }];
    if (indexSet) {
        [_contacts removeObjectsAtIndexes:indexSet];
        [_sectionTitles removeObjectsAtIndexes:indexSet];
    }
    *searchSource = [NSArray arrayWithArray:_searchSource];
    *sectionTitles = [NSArray arrayWithArray:_sectionTitles];
    return _contacts;
}


@end
