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

@interface InvitationManager ()

@property (nonatomic, strong) NSUserDefaults *defaults;

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
        self.defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}


#pragma mark - Data

- (void)addInvitation:(RequestEntity *)requestEntity loginUser:(NSString *)username
{
    NSData *defalutData = [self.defaults objectForKey:username];
    if (defalutData) {
        
        NSMutableArray *requests = [[NSKeyedUnarchiver unarchiveObjectWithData:defalutData] mutableCopy];
        if (requests) {
            [requests addObject:requestEntity];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:requests];
            
            [self.defaults setObject:data forKey:username];
        }
    }
}

- (void)removeInvitation:(RequestEntity *)requestEntity loginUser:(NSString *)username
{
    NSData *defalutData = [self.defaults objectForKey:username];
    
    if (!defalutData) {
        return;
    }
    
    NSMutableArray *requests = [[NSKeyedUnarchiver unarchiveObjectWithData:defalutData] mutableCopy];
    
    RequestEntity *needDelete;
    for (RequestEntity *request in requests) {
        if ([request.groupId isEqualToString:requestEntity.groupId] &&
            [request.receiverUsername isEqualToString:requestEntity.receiverUsername]) {
            needDelete = request;
            break;
        }
    }
    [requests removeObject:needDelete];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:requests];
    
    [self.defaults setObject:data forKey:username];
}

- (NSArray *)getSavedFriendRequests:(NSString *)username
{
    NSData *defalutData = [self.defaults objectForKey:username];
    
    NSArray *requestObjects = [[NSArray alloc] init];
    
    if (defalutData) {
        requestObjects = [NSKeyedUnarchiver unarchiveObjectWithData:defalutData];
    }
    
    return requestObjects;
}

@end


@interface RequestEntity ()<NSCoding>

@end

@implementation RequestEntity

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

