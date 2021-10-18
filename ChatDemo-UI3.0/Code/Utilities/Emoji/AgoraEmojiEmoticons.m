/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraEmojiEmoticons.h"

#import "AgoraEmoji.h"

@implementation AgoraEmojiEmoticons

+ (NSArray *)allEmoticons {
    NSMutableArray *array = [NSMutableArray new];
    NSMutableArray * localAry = [[NSMutableArray alloc] initWithObjects:
                                 [AgoraEmoji emojiWithCode:0x1F60a],
                                 [AgoraEmoji emojiWithCode:0x1F603],
                                 [AgoraEmoji emojiWithCode:0x1F609],
                                 [AgoraEmoji emojiWithCode:0x1F62e],
                                 [AgoraEmoji emojiWithCode:0x1F60b],
                                 [AgoraEmoji emojiWithCode:0x1F60e],
                                 [AgoraEmoji emojiWithCode:0x1F621],
                                 [AgoraEmoji emojiWithCode:0x1F616],
                                 [AgoraEmoji emojiWithCode:0x1F633],
                                 [AgoraEmoji emojiWithCode:0x1F61e],
                                 [AgoraEmoji emojiWithCode:0x1F62d],
                                 [AgoraEmoji emojiWithCode:0x1F610],
                                 [AgoraEmoji emojiWithCode:0x1F607],
                                 [AgoraEmoji emojiWithCode:0x1F62c],
                                 [AgoraEmoji emojiWithCode:0x1F606],
                                 [AgoraEmoji emojiWithCode:0x1F631],
                                 [AgoraEmoji emojiWithCode:0x1F385],
                                 [AgoraEmoji emojiWithCode:0x1F634],
                                 [AgoraEmoji emojiWithCode:0x1F615],
                                 [AgoraEmoji emojiWithCode:0x1F637],
                                 [AgoraEmoji emojiWithCode:0x1F62f],
                                 [AgoraEmoji emojiWithCode:0x1F60f],
                                 [AgoraEmoji emojiWithCode:0x1F611],
                                 [AgoraEmoji emojiWithCode:0x1F496],
                                 [AgoraEmoji emojiWithCode:0x1F494],
                                 [AgoraEmoji emojiWithCode:0x1F319],
                                 [AgoraEmoji emojiWithCode:0x1f31f],
                                 [AgoraEmoji emojiWithCode:0x1f31e],
                                 [AgoraEmoji emojiWithCode:0x1F308],
                                 [AgoraEmoji emojiWithCode:0x1F60d],
                                 [AgoraEmoji emojiWithCode:0x1F61a],
                                 [AgoraEmoji emojiWithCode:0x1F48b],
                                 [AgoraEmoji emojiWithCode:0x1F339],
                                 [AgoraEmoji emojiWithCode:0x1F342],
                                 [AgoraEmoji emojiWithCode:0x1F44d],
                                 nil];
    [array addObjectsFromArray:localAry];
    return array;
}

@end
