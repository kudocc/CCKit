//
//  CCUserSettings.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCUserSettings.h"
#import "NSString+CCKit.h"
#import "NSDictionary+CCKit.h"

static NSString *kUserSettingDirectoryName = @"cckit_user_setting";

@interface CCUserSettings ()

@property (nonatomic) BOOL changed;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSMutableDictionary *settings;

@end

@implementation CCUserSettings

+ (instancetype)sharedUserSettings {
    static dispatch_once_t onceToken;
    static CCUserSettings *settings;
    dispatch_once(&onceToken, ^{
        settings = [[CCUserSettings alloc] init];
    });
    return settings;
}

- (void)loadUserSettingsWithUserId:(NSString *)userId {
    if (userId.length == 0 ||
        [_userId isEqualToString:userId]) {
        return;
    }
    
    if (_userId && _changed) {
        [self synchronize];
    }
    
    _userId = [userId copy];
    _changed = NO;
    
    NSString *dirPath = [NSString cc_documentPath];
    dirPath = [dirPath stringByAppendingPathComponent:kUserSettingDirectoryName];
    _filePath = [dirPath stringByAppendingPathComponent:userId];
    BOOL dir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&dir] && !dir) {
        // load plist with userId
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:_filePath];
        if (settings) {
            _settings = [settings mutableCopy];
        } else {
            _settings = [NSMutableDictionary dictionary];
        }
    } else {
        // the file is absent, create one
        BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!res) {
            NSLog(@"Create directory:%@ failed", dirPath);
        }
        res = [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
        if (!res) {
            NSLog(@"Create file:%@ failed", _filePath);
        }
        _settings = [NSMutableDictionary dictionary];
    }
}

- (nullable id)objectForKey:(NSString *)key {
    return _settings[key];
}

- (void)setObject:(nullable id)value forKey:(NSString *)key {
    // - (void)setObject:(ObjectType)obj forKeyedSubscript:(id<NSCopying>)key;
    // Passing nil will cause any object corresponding to aKey to be removed from the dictionary.
    if (!value) {
        _settings[key] = nil;
        _changed = YES;
    } else {
        if ([value isKindOfClass:NSString.class] ||
            [value isKindOfClass:NSNumber.class] ||
            [value isKindOfClass:NSData.class] ||
            [value isKindOfClass:NSDate.class] ||
            [value isKindOfClass:NSArray.class] ||
            [value isKindOfClass:NSDictionary.class]) {
            _settings[key] = value;
            _changed = YES;
        } else {
            NSLog(@"Not a plist value");
        }
    }
}

- (void)removeObjectForKey:(NSString *)key {
    [self setObject:nil forKey:key];
}

- (nullable NSString *)stringForKey:(NSString *)key {
    return [_settings cc_stringForKey:key];
}

- (nullable NSArray *)arrayForKey:(NSString *)key {
    return [_settings cc_arrayForKey:key];
}

- (nullable NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)key {
    return [_settings cc_dictionaryForKey:key];
}

- (nullable NSData *)dataForKey:(NSString *)key {
    return [_settings cc_objectForKey:key allowClassArray:@[NSData.class]];
}

// bool is not nsnumber???
- (NSInteger)integerForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:NSNumber.class]) {
        NSNumber *number = obj;
        return [number integerValue];
    } else if ([obj isKindOfClass:NSString.class]) {
        NSString *str = obj;
        return [str integerValue];
    } else {
        return 0;
    }
}

- (float)floatForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:NSNumber.class]) {
        NSNumber *number = obj;
        return [number floatValue];
    } else if ([obj isKindOfClass:NSString.class]) {
        NSString *str = obj;
        return [str floatValue];
    } else {
        return 0;
    }
}

- (double)doubleForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:NSNumber.class]) {
        NSNumber *number = obj;
        return [number doubleValue];
    } else if ([obj isKindOfClass:NSString.class]) {
        NSString *str = obj;
        return [str doubleValue];
    } else {
        return 0;
    }
}

- (BOOL)boolForKey:(NSString *)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:NSNumber.class]) {
        NSNumber *number = obj;
        return [number boolValue];
    } else if ([obj isKindOfClass:NSString.class]) {
        NSString *str = obj;
        if ([str compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [str compare:@"TRUE" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
            [str isEqualToString:@"1"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (nullable NSURL *)URLForKey:(NSString *)key {
    // try to set NSURL, then fetch it, check if it a NSURL type
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:NSString.class]) {
        return [NSURL fileURLWithPath:obj];
    } else if ([obj isKindOfClass:NSURL.class]) {
        return obj;
    } else {
        return nil;
    }
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [self setObject:@(value) forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key {
    [self setObject:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString *)key {
    [self setObject:@(value) forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    [self setObject:@(value) forKey:key];
}

// set URL???
//- (void)setURL:(nullable NSURL *)url forKey:(NSString *)key {
//    url.absoluteString string
//}

- (BOOL)synchronize {
    if (!_changed) {
        return YES;
    }
    BOOL r = [_settings writeToFile:_filePath atomically:YES];
    if (!r) {
        NSLog(@"synchronize failed");
    } else {
        _changed = YES;
    }
    return r;
}

@end
