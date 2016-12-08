//
//  AudioFileManager.h
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioFileManager : NSObject

+ (instancetype)sharedManager;

+ (BOOL)createAudioDirectory;
+ (BOOL)createVideoDirectory;

+ (NSString *)audioDirectory;
+ (NSString *)videoDirectory;

+ (NSArray<NSString *> *)audioFilePathInAudioDirectory;
+ (NSArray<NSString *> *)videoFilePathInAudioDirectory;

@end
