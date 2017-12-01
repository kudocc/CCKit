//
//  CCKitRunloopResearchManager.m
//  CCKitDemo
//
//  Created by rui yuan on 2017/11/30.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "CCKitRunloopResearchManager.h"

@implementation CCKitRunloopResearchManager {
    CFRunLoopObserverRef observer;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static CCKitRunloopResearchManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[CCKitRunloopResearchManager alloc] init];
    });
    return instance;
}

void CCRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    CCKitRunloopResearchManager *manager = (__bridge CCKitRunloopResearchManager *)info;
    NSString *str = [manager descriptionFromCFRunloopActivity:activity];
    NSLog(@"%@", str);
}

- (NSString *)descriptionFromCFRunloopActivity:(CFRunLoopActivity)act {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(runloop);
    NSString *strMode = (__bridge NSString *)mode;
    NSMutableString *str = [[NSString stringWithFormat:@"runloop mode : %@, activity", strMode] mutableCopy];
    if (act & kCFRunLoopEntry) {
        [str appendString:@"-Entry"];
    }
    if (act & kCFRunLoopBeforeTimers) {
        [str appendString:@"-BeforeTimers"];
    }
    if (act & kCFRunLoopBeforeSources) {
        [str appendString:@"-BeforeSources"];
    }
    if (act & kCFRunLoopBeforeWaiting) {
        [str appendString:@"-BeforeWaiting"];
    }
    if (act & kCFRunLoopAfterWaiting) {
        [str appendString:@"-AfterWaiting"];
    }
    if (act & kCFRunLoopExit) {
        [str appendString:@"-Exit"];
    }
    return [str copy];
}

/*
 kCFRunLoopEntry = (1UL << 0),
 kCFRunLoopBeforeTimers = (1UL << 1),
 kCFRunLoopBeforeSources = (1UL << 2),
 kCFRunLoopBeforeWaiting = (1UL << 5),
 kCFRunLoopAfterWaiting = (1UL << 6),
 kCFRunLoopExit = (1UL << 7),
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 */
- (void)startMonitorRunloop {
    CFRunLoopRef mainRunloop = CFRunLoopGetMain();
    CFRunLoopObserverContext ctx;
    ctx.version = 1;
    ctx.retain = NULL;
    ctx.release = NULL;
    ctx.copyDescription = NULL;
    ctx.info = (__bridge void *)self;
    
    observer = CFRunLoopObserverCreate(NULL, kCFRunLoopAllActivities, YES, 0, CCRunLoopObserverCallBack, &ctx);
    CFRunLoopAddObserver(mainRunloop, observer, kCFRunLoopCommonModes);
}

- (void)stopMonitorRunloop {
    if (observer) {
        CFRunLoopRef mainRunloop = CFRunLoopGetMain();
        CFRunLoopRemoveObserver(mainRunloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
        observer = NULL;
    }
    
}

@end
