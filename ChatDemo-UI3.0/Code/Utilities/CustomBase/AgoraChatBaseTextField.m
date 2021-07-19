//
//  AgoraChatBaseTextField.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/7/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatBaseTextField.h"

@implementation AgoraChatBaseTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self updateForDarkMode];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateForDarkMode];

}

- (void)updateForDarkMode {
    self.backgroundColor = UIColor.whiteColor;
}



@end
