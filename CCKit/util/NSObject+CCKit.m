//
//  NSObject+CCKit.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSObject+CCKit.h"

@implementation NSObject (CCKit)

- (id)cc_deepCopy {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (data) {
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return obj;
    }
    return nil;
}

@end
