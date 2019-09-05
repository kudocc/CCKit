//
//  CCUtility.m
//  CCKitDemo
//
//  Created by rui yuan on 2019/9/5.
//  Copyright © 2019 KudoCC. All rights reserved.
//

#import "CCUtility.h"

@implementation CCUtility

+ (NSTimeInterval)calculateTime:(void (^)(void))block
{
    NSDate *date = [NSDate date];
    block();
    return [[NSDate date] timeIntervalSinceDate:date];
}

@end
