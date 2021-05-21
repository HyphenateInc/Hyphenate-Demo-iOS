/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

#define MAKE_Q(x) @#x
#define MAKE_Agora(x,y) MAKE_Q(x##y)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunicode"
#define MAKE_AgoraOJI(x) MAKE_Agora(\U000,x)
#pragma clang diagnostic pop

#define AgoraOJI_METHOD(x,y) + (NSString *)x { return MAKE_AgoraOJI(y); }
#define AgoraOJI_HMETHOD(x) + (NSString *)x;
#define AgoraOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@interface AgoraEmoji : NSObject

+ (NSString *)emojiWithCode:(int)code;

+ (NSArray *)allEmoji;

+ (BOOL)stringContainsEmoji:(NSString *)string;

@end
