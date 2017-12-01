//
//  CCKitRunloopResearchManager.h
//  CCKitDemo
//
//  Created by rui yuan on 2017/11/30.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCKitRunloopResearchManager : NSObject

+ (instancetype)sharedManager;

- (void)startMonitorRunloop;
- (void)stopMonitorRunloop;

@end
