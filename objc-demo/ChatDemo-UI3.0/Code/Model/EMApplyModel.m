/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMApplyModel.h"

@implementation EMApplyModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_recordId forKey:@"recordId"];
    [aCoder encodeObject:_applyHyphenateId forKey:@"applyHyphenateId"];
    [aCoder encodeObject:_applyNickName forKey:@"applyNickName"];
    [aCoder encodeObject:_reason forKey:@"reason"];
    [aCoder encodeObject:_receiverHyphenateId forKey:@"receiverHyphenateId"];
    [aCoder encodeObject:_receiverNickname forKey:@"receiverNickname"];
    [aCoder encodeInteger:_style forKey:@"style"];
    [aCoder encodeObject:_groupId forKey:@"groupId"];
    [aCoder encodeObject:_groupSubject forKey:@"subject"];
    [aCoder encodeInteger:_groupMemberCount forKey:@"groupMemberCount"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        _recordId = [aDecoder decodeObjectForKey:@"recordId"];
        _applyHyphenateId = [aDecoder decodeObjectForKey:@"applyHyphenateId"];
        _applyNickName = [aDecoder decodeObjectForKey:@"applyNickName"];
        _reason = [aDecoder decodeObjectForKey:@"reason"];
        _receiverHyphenateId = [aDecoder decodeObjectForKey:@"receiverHyphenateId"];
        _receiverNickname = [aDecoder decodeObjectForKey:@"receiverNickname"];
        _style = [aDecoder decodeIntegerForKey:@"style"];
        _groupId = [aDecoder decodeObjectForKey:@"groupId"];
        _groupSubject = [aDecoder decodeObjectForKey:@"subject"];
        _groupMemberCount = [aDecoder decodeIntegerForKey:@"groupMemberCount"];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordId = [self createRecordId];
        _applyHyphenateId = @"";
        _applyNickName = @"";
        _reason = @"";
        NSString *currentHyphenateId = [EMClient sharedClient].currentUsername;
        _receiverHyphenateId = currentHyphenateId;
        _receiverNickname = currentHyphenateId;
        _style = EMApplyStyle_contact;
        _groupId = @"";
        _groupSubject = @"";
        _groupMemberCount = 0;
    }
    return self;
}

- (NSString *)createRecordId {
    long long currentTime= (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    int randVal = arc4random() % 10000;
    NSString *recordId = [NSString stringWithFormat:@"%lld_%d",currentTime,randVal];
    return recordId;
}



@end
