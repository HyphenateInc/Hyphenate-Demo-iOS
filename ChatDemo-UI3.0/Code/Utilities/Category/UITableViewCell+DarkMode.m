//
//  UITableViewCell+DarkMode.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/7/14.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "UITableViewCell+DarkMode.h"
#import <objc/runtime.h>
@implementation UITableViewCell (DarkMode)

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = UIColor.whiteColor;
}


@end
