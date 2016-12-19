//
//  CCMmapUserSettings.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCMmapUserSettings.h"
#import "NSString+CCKit.h"
#import "NSDictionary+CCKit.h"
#import <sys/mman.h>

#define MEM_PAGE_SIZE 4096

static NSString *kUserSettingDirectoryName = @"mmap_user_setting";

@interface CCMmapUserSettings () {
    FILE *_file;
    unsigned int _memoryLength;
    unsigned char *_memory;
}

@property (nonatomic) BOOL changed;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSMutableDictionary *settings;

@end

@implementation CCMmapUserSettings

+ (instancetype)sharedUserSettings {
    static dispatch_once_t onceToken;
    static CCMmapUserSettings *settings;
    dispatch_once(&onceToken, ^{
        settings = [[CCMmapUserSettings alloc] init];
    });
    return settings;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _memory = NULL;
        _memoryLength = 0;
    }
    return self;
}

- (void)loadUserSettingsWithUserId:(NSString *)userId {
    if (userId.length == 0 ||
        [_userId isEqualToString:userId]) {
        return;
    }
    
    if (_userId && _changed) {
        [self synchronize];
    }
    
    if (_userId) {
        if (_memory) {
            int res = munmap(_memory, _memoryLength);
            if (res == -1) {
                NSLog(@"munmap error");
            }
            _memory = NULL;
            _memoryLength = 0;
        }
        
        if (_file) {
            fclose(_file);
            _file = NULL;
        }
    }
    
    _userId = [userId copy];
    _changed = NO;
    _settings = nil;
    
    NSString *dirPath = [NSString cc_documentPath];
    dirPath = [dirPath stringByAppendingPathComponent:kUserSettingDirectoryName];
    _filePath = [dirPath stringByAppendingPathComponent:userId];
    BOOL dir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&dir] && !dir) {
        // Open for reading and writing.  The stream is positioned at the beginning of the file.
        _file = fopen([_filePath UTF8String], "r+");
        if (!_file) {
            NSLog(@"open file r+ error");
            return;
        }
        fseek(_file, 0, SEEK_END);
        long fileLength = ftell(_file);
        if (fileLength <= sizeof(_memoryLength) ||
            fileLength % MEM_PAGE_SIZE != 0) {
            // There must be something wrong!!! Don't use the file data, next synchronize method will override file data.
            _settings = [NSMutableDictionary dictionary];
            return;
        }
        _memory = (unsigned char *)mmap(NULL, fileLength, PROT_READ|PROT_WRITE, MAP_SHARED, fileno(_file), 0);
        _memoryLength = (unsigned int)fileLength;
        if (_memory == MAP_FAILED) {
            return;
        }
        // 4 bytes length
        unsigned int dataLength = 0;
        memcpy(&dataLength, _memory, sizeof(_memoryLength));
        dataLength -= sizeof(_memoryLength);
        if (dataLength > 0) {
            unsigned char *p = _memory + sizeof(_memoryLength);
            NSData *data = [NSData dataWithBytesNoCopy:p length:dataLength freeWhenDone:NO];
            NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data
                                                                           options:NSPropertyListImmutable
                                                                            format:NULL error:nil];
            if (!dict) {
                dict = @{};
            }
            _settings = [dict mutableCopy];
        } else {
            _settings = [NSMutableDictionary dictionary];
        }
    } else {
        // the file is absent, create one and write one page size to it
        BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                             withIntermediateDirectories:YES attributes:nil error:nil];
        if (!res) {
            NSLog(@"Create directory:%@ failed", dirPath);
            return;
        }
        unsigned char c[MEM_PAGE_SIZE] = {0};
        _file = fopen([_filePath UTF8String], "w+");
        if (!_file) {
            NSLog(@"open file w+ error");
            return;
        }
        // The function fwrite() returns a value less than nitems only if a write error has occurred.
        size_t nitems = fwrite(c, 1, MEM_PAGE_SIZE, _file);
        if (nitems != MEM_PAGE_SIZE) {
            fclose(_file);
            _file = NULL;
            return;
        }
        _memory = (unsigned char *)mmap(NULL, MEM_PAGE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fileno(_file), 0);
        _memoryLength = MEM_PAGE_SIZE;
        if (_memory == MAP_FAILED) {
            fclose(_file);
            _file = NULL;
            return;
        }
#ifdef DEBUG
        NSLog(@"memory map file success, size is %@", @(_memoryLength));
#endif
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

- (BOOL)synchronize {
    if (!_changed) {
        return YES;
    }
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:_settings format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    // even if data.length + sizeof(_memoryLength) is a multiple of MEM_PAGE_SIZE, we need one more page.
    unsigned int pageCount = (unsigned int)(data.length + sizeof(_memoryLength)) / MEM_PAGE_SIZE + 1;
    unsigned int fileSize = pageCount * MEM_PAGE_SIZE;
    if (fileSize != _memoryLength) {
        if (_memory) {
            munmap(_memory, _memoryLength);
            _memory = NULL;
            _memoryLength = 0;
        }
        
        int res = ftruncate(fileno(_file), fileSize);
        if (res == -1) {
            // truncate file error
            fclose(_file);
            _file = NULL;
            return NO;
        }
        // re-map the file
        _memory = (unsigned char *)mmap(NULL, fileSize, PROT_READ|PROT_WRITE, MAP_SHARED, fileno(_file), 0);
        _memoryLength = (unsigned int)fileSize;
        if (_memory == MAP_FAILED) {
            _memory = NULL;
            fclose(_file);
            _file = NULL;
            return NO;
        }
#ifdef DEBUG
        NSLog(@"memory map file success, size is %@", @(_memoryLength));
#endif
    }
    
    if (_memory) {
        unsigned int length = (unsigned int)data.length;
        length += sizeof(length);
        memcpy(_memory, &length, sizeof(length));
        memcpy(_memory+sizeof(length), data.bytes, data.length);
    }
    return YES;
}

@end
