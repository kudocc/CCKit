//
//  NSObject+CCKit.m
//  demo
//
//  Created by KudoCC on 16/5/28.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSObject+CCKit.h"
#import <objc/runtime.h>

@implementation NSObject (CCKit)

- (id)cc_deepCopy {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (data) {
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return obj;
    }
    return nil;
}

+ (void)logMethodNames {
    unsigned int count = 0;
    Class cls = self;
    do {
        NSLog(@"class name:%@", NSStringFromClass(cls));
        Method *methodList = class_copyMethodList(cls, &count);
        for (unsigned int i = 0; i < count; ++i) {
            Method m = methodList[i];
            SEL name = method_getName(m);
            NSString *selName = NSStringFromSelector(name);
            NSLog(@"%@", selName);
        }
        if (methodList) {
            free(methodList);
        }
        cls = class_getSuperclass(cls);
    } while (cls && cls != [NSObject class]);
}

@end
