//
//  CCAsyncLayer.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCAsyncLayer.h"
#import <UIKit/UIKit.h>

@implementation CCAsyncLayer {
    NSInteger _displayCycle;
}

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"asyncDisplay"]) {
        return @(YES);
    } else {
        return [super defaultValueForKey:key];
    }
}

- (instancetype)init {
    self = [super init];
    self.contentsScale = [UIScreen mainScreen].scale;
    _asyncDisplay = YES;
    _displayCycle = 0;
    
    return self;
}

- (void)setNeedsDisplay {
    [self cancelCurrentDisplay];
    [super setNeedsDisplay];
}

- (void)display {
    id<CCAsyncLayerDelegate> asyncDelegate = self.delegate;
    CCAsyncLayerDisplayTask *task = [asyncDelegate newAsyncDisplayTask];
    if (!task) {
        return;
    }
    
    NSInteger cycle = _displayCycle;
    BOOL(^isCanceled)() = ^BOOL() {
        return cycle != _displayCycle;
    };
    
    task.willDisplay(self);
    
    BOOL opaque = self.opaque;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (_asyncDisplay) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (isCanceled()) {
                task.didDisplay(self, NO);
                return;
            }
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            task.display(context, self.bounds.size, isCanceled);
            if (isCanceled()) {
                UIGraphicsEndImageContext();
                task.didDisplay(self, NO);
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCanceled()) {
                    task.didDisplay(self, NO);
                    return;
                }
                self.contents = (__bridge id)image.CGImage;
                task.didDisplay(self, YES);
            });
        });
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        task.display(context, self.bounds.size, nil);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id)image.CGImage;
        task.didDisplay(self, YES);
    }
}

- (void)cancelCurrentDisplay {
    ++_displayCycle;
}

@end


@implementation CCAsyncLayerDisplayTask

@end