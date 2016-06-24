/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import "AddFriendCell.h"

@implementation AddFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    if (self) {

        self.addLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, 0, 60, 30)];
        self.addLabel.backgroundColor = [UIColor HIPrimaryColor];
        self.addLabel.textAlignment = NSTextAlignmentCenter;
        self.addLabel.text = NSLocalizedString(@"add", @"Add");
        self.addLabel.textColor = [UIColor whiteColor];
        self.addLabel.font = [UIFont systemFontOfSize:14.0];
        self.addLabel.layer.cornerRadius = 6.0f;
        self.addLabel.layer.masksToBounds = YES;
       
        [self.contentView addSubview:self.addLabel];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.textLabel.frame;
    rect.size.width -= 70;
    self.textLabel.frame = rect;
    
    rect = self.addLabel.frame;
    rect.origin.y = (self.frame.size.height - 30) / 2;
    self.addLabel.frame = rect;
}

@end
