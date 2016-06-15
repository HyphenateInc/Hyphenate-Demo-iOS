//
//  UIColor+Hyphenate.m
//  ChatDemo-UI3.0
//
//  Created by Hyphenate on 6/3/16.
//  Copyright © 2016 Hyphenate. All rights reserved.
//

#import "UIColor+Hyphenate.h"

@implementation UIColor (Hyphenate)

+ (UIColor *)HIPrimaryColor
{
    return [[self class] colorFromHexString:@"#A0D830"];
}

+ (UIColor *)HIGreenDarkColor
{
    return [[self class] colorFromHexString:@"#7d9b3c"];
}

+ (UIColor *)HIGreenLightColor
{
    return [[self class] colorFromHexString:@"#9cc13b"];
}

+ (UIColor *)HIRedColor
{
    return [[self class] colorFromHexString:@"#cc0000"];
}

+ (UIColor *)HIGrayLightColor
{
    return [[self class] colorFromHexString:@"#EFEFEF"];
}



+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
