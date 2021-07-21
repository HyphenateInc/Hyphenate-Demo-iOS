//
//  AgoraChatBaseTableview.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/7/15.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatBaseTableview.h"

@implementation AgoraChatBaseTableview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self backgroudColorForDarkMode];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self backgroudColorForDarkMode];
}


- (void)backgroudColorForDarkMode {
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.whiteColor;
            } else {
                return UIColor.whiteColor;
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

@end
