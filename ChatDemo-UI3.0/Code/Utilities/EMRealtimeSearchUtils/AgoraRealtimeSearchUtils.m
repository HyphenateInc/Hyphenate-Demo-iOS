/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraRealtimeSearchUtils.h"
#import "IAgoraRealtimeSearch.h"


static AgoraRealtimeSearchUtils *defaultUtils = nil;

@interface AgoraRealtimeSearchUtils()

@property (nonatomic, weak) id source;

@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, copy) AgoraRealtimeSearchResultsBlock resultBlock;

@property (nonatomic, strong) NSThread *searchThread;

@end


@implementation AgoraRealtimeSearchUtils

+ (instancetype)defaultUtil {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(){
        defaultUtils = [[AgoraRealtimeSearchUtils alloc] init];
    });
    return defaultUtils;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
#pragma mark - private

- (void)realtimeSearchDidStart {
    if (_searchThread) {
        [_searchThread cancel];
    }
    _searchThread = [[NSThread alloc] initWithTarget:self selector:@selector(realtimeSearchBegin) object:nil];
    [_searchThread start];
}

- (void)realtimeSearchBegin {
    
    NSMutableArray *results = [NSMutableArray array];
    for (id obj in _source) {
        NSString * searchKey = @"";
        if ([obj conformsToProtocol:@protocol(IAgoraRealtimeSearch)]) {
            id<IAgoraRealtimeSearch> searchModel = (id<IAgoraRealtimeSearch>)obj;
            searchKey = [searchModel.searchKey lowercaseString];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            searchKey = [(NSString *)obj lowercaseString];
        }
        else {
            continue;
        }
        if (_searchString.length == 0) {
            break;
        }
        if ([searchKey rangeOfString:_searchString].length > 0) {
            [results addObject:obj];
        }
    }
    if (_resultBlock) {
        _resultBlock(results);
    }
}

#pragma mark - public

- (void)realtimeSearchWithSource:(id)source
                    searchString:(NSString *)searchString
                     resultBlock:(AgoraRealtimeSearchResultsBlock)block
{
    _resultBlock = block;
    if (!source || searchString.length == 0) {
        if (_resultBlock) {
            _resultBlock(source);
        }
        return;
    }
    _source = source;
    _searchString = [searchString lowercaseString];
    [self realtimeSearchDidStart];
}

- (void)realtimeSearchDidFinish {
    [_searchThread cancel];
    _source = nil;
    _searchString = nil;
}

@end
