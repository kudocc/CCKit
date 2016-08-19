//
//  CCTextRunDelegate.m
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextRunDelegate.h"

static void CCCTRunDelegateDeallocateCallback(void * refCon) {
    return;
}

static CGFloat CCCTRunDelegateGetAscentCallback(void * refCon) {
    CCTextRunDelegate *delegate = (__bridge CCTextRunDelegate *)refCon;
    return delegate.ascent;
}

static CGFloat CCCTRunDelegateGetDescentCallback(void * refCon) {
    CCTextRunDelegate *delegate = (__bridge CCTextRunDelegate *)refCon;
    return delegate.descent;
}

static CGFloat CCCTRunDelegateGetWidthCallback(void * refCon) {
    CCTextRunDelegate *delegate = (__bridge CCTextRunDelegate *)refCon;
    return delegate.width;
}

@implementation CCTextRunDelegate

- (CTRunDelegateRef)createCTRunDelegateRef {
    const CTRunDelegateCallbacks callbacks = {kCTRunDelegateCurrentVersion, &CCCTRunDelegateDeallocateCallback, &CCCTRunDelegateGetAscentCallback, &CCCTRunDelegateGetDescentCallback, &CCCTRunDelegateGetWidthCallback};
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)self);
    return runDelegate;
}

@end
