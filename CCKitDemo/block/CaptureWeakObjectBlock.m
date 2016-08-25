//
//  CaptureWeakObjectBlock.m
//  demo
//
//  Created by KudoCC on 16/5/20.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

// can't be compiled
// error: cannot create __weak
// reference because the current deployment target does not support weak references
// __attribute__((objc_ownership(weak))) NSObject *wObj = o;


typedef void(^captureScalar)(void);

captureScalar _block;

void blockMethod() {
    NSObject *o = [NSObject new];
    __weak NSObject *wObj = o;
    captureScalar block = ^() {
        NSObject *oo = wObj;
    };
    
    [block copy];
}

