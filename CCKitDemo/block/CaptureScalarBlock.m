//
//  CaptureScalarBlock.m
//  demo
//
//  Created by KudoCC on 16/5/20.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^captureScalar)(void);

captureScalar _block;

void blockMethod() {
    int a = 10;
    __block int mutableA = 100;
    captureScalar block = ^() {
        int b = a;
        ++b;
        mutableA = 1024;
    };
    
    [block copy];
}

