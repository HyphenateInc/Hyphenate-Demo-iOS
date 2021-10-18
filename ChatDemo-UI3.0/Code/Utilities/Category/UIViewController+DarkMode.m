//
//  UIViewController+DarkMode.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/7/15.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "UIViewController+DarkMode.h"
#import <objc/runtime.h>

@implementation UIViewController (DarkMode)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzleInstanceSelector:@selector(viewDidLoad) withSelector:@selector(viewDidLoadDarkMode)];
    });
}


- (void)viewDidLoadDarkMode {
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {

            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.blackColor;
            } else {
                return UIColor.blackColor;
            }
        }]};
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
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

+ (void)swizzleInstanceSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success)
    {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@end
