//
//  UITextField+DarkMode.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/7/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "UITextField+DarkMode.h"
#import <objc/runtime.h>

@implementation UITextField (DarkMode)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzleInstanceSelector:@selector(setPlaceholder:) withSelector:@selector(updatePlaceholder:)];
    });
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

- (void)updatePlaceholder:(NSString *)placeholder {
    NSLog(@"%s class:%@ placeholder:%@",__func__,NSStringFromClass([self class]),placeholder);
    if (placeholder == nil) {
        return;
    }
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: UIColor.grayColor}];
    self.textColor = UIColor.blackColor;
    
}

- (void)adaptForDarkMode {
    self.backgroundColor = UIColor.whiteColor;
}

@end
