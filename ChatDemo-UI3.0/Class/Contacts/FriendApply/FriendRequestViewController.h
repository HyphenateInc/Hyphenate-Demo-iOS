/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import <UIKit/UIKit.h>

typedef enum{
    HIRequestTypeFriend            = 0,
    HIRequestTypeReceivedGroupInvitation,
    HIRequestTypeJoinGroup,
} HIRequestType;

@interface FriendRequestViewController : UITableViewController
{
    NSMutableArray *_dataSource;
}

@property (strong, nonatomic, readonly) NSMutableArray *dataSource;

+ (instancetype)shareController;

- (void)addNewRequest:(NSDictionary *)dictionary;

- (void)loadDataSourceFromLocalDB;

- (void)clear;

@end
