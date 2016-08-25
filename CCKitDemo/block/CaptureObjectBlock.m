//
//  CaptureObjectBlock.m
//  demo
//
//  Created by KudoCC on 16/5/20.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^captureScalar)(void);

captureScalar _block;

void blockMethod() {
    NSObject *o = [NSObject new];
    __block NSObject *mutableO = [NSObject new];
    captureScalar block = ^() {
        NSObject *oo = o;
        mutableO = nil;
    };
    
    [block copy];
}

