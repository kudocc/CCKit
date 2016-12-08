//
//  AudioFileManager.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioFileManager.h"
#import "NSString+CCKit.h"

@implementation AudioFileManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static AudioFileManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[AudioFileManager alloc] init];
    });
    return manager;
}


+ (NSString *)audioDirectory {
    NSString *path = [NSString cc_documentPath];
    return [path stringByAppendingPathComponent:@"audio"];
}
+ (NSString *)videoDirectory {
    NSString *path = [NSString cc_documentPath];
    return [path stringByAppendingPathComponent:@"video"];
}


+ (BOOL)createAudioDirectory {
    NSString *directory = [self audioDirectory];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir] && isDir) {
        return YES;
    }
    NSError *error = nil;
    BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:NULL error:&error];
    if (!res) {
        NSLog(@"create audio directory path failed:%@", error.localizedDescription);
    }
    return res;
}
+ (BOOL)createVideoDirectory {
    NSString *directory = [self videoDirectory];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir] && isDir) {
        return YES;
    }
    NSError *error = nil;
    BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:NULL error:&error];
    if (!res) {
        NSLog(@"create video directory path failed:%@", error.localizedDescription);
    }
    return res;
}


+ (NSArray<NSString *> *)audioFilePathInAudioDirectory {
    NSString *dir = [self audioDirectory];
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self audioDirectory] error:NULL];
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSString *fileName in fileNames) {
        NSString *file = [dir stringByAppendingPathComponent:fileName];
        [mArr addObject:file];
    }
    return [mArr copy];
}
+ (NSArray<NSString *> *)videoFilePathInAudioDirectory {
    NSString *dir = [self videoDirectory];
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self audioDirectory] error:NULL];
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSString *fileName in fileNames) {
        NSString *file = [dir stringByAppendingPathComponent:fileName];
        [mArr addObject:file];
    }
    return [mArr copy];
}

@end
