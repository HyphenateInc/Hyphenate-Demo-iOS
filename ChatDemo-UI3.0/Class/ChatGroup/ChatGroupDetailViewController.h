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
    GroupOccupantTypeOwner,
    GroupOccupantTypeMember,
}GroupOccupantType;

@interface ChatGroupDetailViewController : UITableViewController

- (instancetype)initWithGroup:(EMGroup *)chatGroup;

- (instancetype)initWithGroupId:(NSString *)chatGroupId;

@end
