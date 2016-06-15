/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "InvitationManager.h"

@interface InvitationManager (){
    NSUserDefaults *_defaults;
}

@end

static InvitationManager *sharedInstance = nil;
@implementation InvitationManager


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init{
    if (self = [super init]) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}


#pragma mark - Data

- (void)addInvitation:(ApplyEntity *)applyEntity loginUser:(NSString *)username
{
    NSData *defalutData = [_defaults objectForKey:username];
    
    NSMutableArray *requests = [[NSKeyedUnarchiver unarchiveObjectWithData:defalutData] mutableCopy];
    
    [requests addObject:applyEntity];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:requests];
    
    [_defaults setObject:data forKey:username];
}

- (void)removeInvitation:(ApplyEntity *)applyEntity loginUser:(NSString *)username
{
    NSData *defalutData = [_defaults objectForKey:username];
    
    if (!defalutData) {
        return;
    }
    
    NSMutableArray *requests = [[NSKeyedUnarchiver unarchiveObjectWithData:defalutData] mutableCopy];
    
    ApplyEntity *needDelete;
    for (ApplyEntity *request in requests) {
        if ([request.groupId isEqualToString:applyEntity.groupId] &&
            [request.receiverUsername isEqualToString:applyEntity.receiverUsername]) {
            needDelete = request;
            break;
        }
    }
    [requests removeObject:needDelete];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:requests];
    
    [_defaults setObject:data forKey:username];
}

- (NSArray *)getSavedFriendRequests:(NSString *)username
{
    NSData *defalutData = [_defaults objectForKey:username];
    
    NSArray *requestObjects = [[NSArray alloc] init];
    
    if (defalutData) {
        requestObjects = [NSKeyedUnarchiver unarchiveObjectWithData:defalutData];
    }
    
    return requestObjects;
}

@end


@interface ApplyEntity ()<NSCoding>

@end

@implementation ApplyEntity

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_applicantUsername forKey:@"applicantUsername"];
    [aCoder encodeObject:_applicantNick forKey:@"applicantNick"];
    [aCoder encodeObject:_reason forKey:@"reason"];
    [aCoder encodeObject:_receiverUsername forKey:@"receiverUsername"];
    [aCoder encodeObject:_receiverNick forKey:@"receiverNick"];
    [aCoder encodeObject:_style forKey:@"style"];
    [aCoder encodeObject:_groupId forKey:@"groupId"];
    [aCoder encodeObject:_groupSubject forKey:@"subject"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        _applicantUsername = [aDecoder decodeObjectForKey:@"applicantUsername"];
        _applicantNick = [aDecoder decodeObjectForKey:@"applicantNick"];
        _reason = [aDecoder decodeObjectForKey:@"reason"];
        _receiverUsername = [aDecoder decodeObjectForKey:@"receiverUsername"];
        _receiverNick = [aDecoder decodeObjectForKey:@"receiverNick"];
        _style = [aDecoder decodeObjectForKey:@"style"];
        _groupId = [aDecoder decodeObjectForKey:@"groupId"];
        _groupSubject = [aDecoder decodeObjectForKey:@"subject"];
        
    }
    
    return self;
}

@end

