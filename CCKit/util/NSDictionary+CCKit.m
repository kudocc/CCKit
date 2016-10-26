//
//  NSDictionary+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/6.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSDictionary+CCKit.h"

@implementation NSDictionary (CCKit)

- (id)cc_objectForKeyPath:(NSString *)keyPath {
    return [self cc_objectForKeyPath:keyPath separator:@"."];
}

- (id)cc_objectForKeyPath:(NSString *)keyPath separator:(NSString *)separator {
    NSArray *array = [keyPath componentsSeparatedByString:separator];
    if ([array count] == 0) return nil;
    NSDictionary *value = self;
    for (NSString *key in array) {
        value = value[key];
        if (!value || ![value isKindOfClass:[NSDictionary class]]) {
            break;
        }
    }
    return value;
}

- (NSString *)cc_stringForKey:(NSString *)key {
    id obj = self[key];
    if (![obj isKindOfClass:[NSString class]]) {
        return nil;
    }
    return obj;
}

- (NSNumber *)cc_numberForKey:(NSString *)key {
    id obj = self[key];
    if (![obj isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    return obj;
}

- (NSArray *)cc_arrayForKey:(NSString *)key {
    id obj = self[key];
    if (![obj isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return obj;
}

- (NSDictionary *)cc_dictionaryForKey:(NSString *)key {
    id obj = self[key];
    if (![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return obj;
}

- (NSString *)cc_stringAllowNSNumberForKey:(NSString *)key {
    id obj = self[key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj description];
    }
    return nil;
}

@end


@implementation NSMutableDictionary (CCKit)

- (void)cc_setObject:(id)object forKeyPath:(NSString *)keyPath {
    return [self cc_setObject:object forKeyPath:keyPath separator:@"."];
}

- (void)cc_setObject:(id)object forKeyPath:(NSString *)keyPath separator:(NSString *)separator {
    NSArray *array = [keyPath componentsSeparatedByString:separator];
    if ([array count] == 0) return;
    __block NSMutableDictionary *mutableDictionary = self;
    __block BOOL error = NO;
    [array enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (array.count > idx+1) {
            NSMutableDictionary *mTmpDict = mutableDictionary[key];
            if (mTmpDict && ![mTmpDict isKindOfClass:[NSMutableDictionary class]]) {
                *stop = YES;
                error = YES;
                return;
            }
            if (!mTmpDict) {
                mTmpDict = [NSMutableDictionary dictionary];
            }
            [mutableDictionary setObject:mTmpDict forKey:key];
            mutableDictionary = mTmpDict;
        } else {
            NSAssert([mutableDictionary isKindOfClass:[NSMutableDictionary class]], @"logic error");
            [mutableDictionary setObject:object forKey:key];
        }
    }];
}

@end
