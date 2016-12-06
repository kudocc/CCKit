//
//  CABasicAnimationTestViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "CABasicAnimationTestViewController.h"

@interface CABasicAnimationTestViewController () <CAAnimationDelegate>

@property (nonatomic, strong) CALayer *layer;
@property UIView *viewTest;

@end

@implementation CABasicAnimationTestViewController

- (void)dealloc {
    self.layer.delegate = nil;
}

- (void)initView {
    self.enableTap = YES;
    
    _layer = [[CALayer alloc] init];
    UIImage *image = [UIImage imageNamed:@"conan1"];
    _layer.frame = CGRectMake(10.0, 64.0, image.size.width, image.size.height);
    _layer.contents = (__bridge id)image.CGImage;
    [self.view.layer addSublayer:_layer];
    
    _viewTest = [[UIView alloc] init];
    _viewTest.frame = CGRectOffset(_layer.frame, 0, _layer.frame.size.height + 10);
    _viewTest.layer.contents = (__bridge id)image.CGImage;
    [self.view addSubview:_viewTest];
}

- (CABasicAnimation *)positionAnimationFrom:(CGPoint)from to:(CGPoint)to duration:(CFTimeInterval)duration {
    CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAni.fromValue = [NSValue valueWithCGPoint:from];
    basicAni.toValue = [NSValue valueWithCGPoint:to];
    basicAni.duration = duration;
    basicAni.delegate = self;
    return basicAni;
}

- (CABasicAnimation *)boundsAnimationFrom:(CGRect)from to:(CGRect)to duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:from];
    animation.toValue = [NSValue valueWithCGRect:to];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = duration;
    return animation;
}

- (CABasicAnimation *)opacityAnimationFrom:(float)from to:(float)to duration:(CFTimeInterval)duration {
    CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAni.fromValue = @(from);
    basicAni.toValue = @(to);
    basicAni.duration = duration;
    return basicAni;
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    CFTimeInterval duration = 3.0;
    
    CGPoint pFrom = CGPointMake(30, 0);
    CGPoint p = CGPointMake(_layer.position.x, ScreenHeight-_layer.bounds.size.height);
    [_layer addAnimation:[self positionAnimationFrom:pFrom to:p duration:duration] forKey:@"position"];
    
    CGFloat xInset = -30.0;
    CGFloat yInset = _layer.bounds.size.height * xInset / _layer.bounds.size.width;
    CGRect boundsFrom = UIEdgeInsetsInsetRect(_layer.bounds, UIEdgeInsetsMake(yInset, xInset, yInset, xInset));
    [_layer addAnimation:[self boundsAnimationFrom:boundsFrom to:_layer.bounds duration:duration] forKey:@"bounds"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _layer.position = p;
    [CATransaction commit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (_layer.presentationLayer) {
            
            CGPoint p = CGPointMake(_layer.position.x, ScreenHeight);
            CGPoint pFrom = _layer.presentationLayer.position;
            [_layer addAnimation:[self positionAnimationFrom:pFrom to:p duration:duration] forKey:@"position"];
            
            CGRect boundsFrom = _layer.presentationLayer.bounds;
            [_layer addAnimation:[self boundsAnimationFrom:boundsFrom to:_layer.bounds duration:duration] forKey:@"bounds"];
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            _layer.position = p;
            [CATransaction commit];
        }
    });

    // animate layer backed view
    [_viewTest.layer addAnimation:[self positionAnimationFrom:_viewTest.layer.position to:p duration:duration] forKey:@"position"];
    [_viewTest.layer addAnimation:[self opacityAnimationFrom:1 to:0 duration:duration] forKey:@"opacity"];
    _viewTest.layer.position = p;
    _viewTest.layer.opacity = 0;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSNumber *number = [anim valueForKey:@"cancelKey"];
    NSLog(@"%@, %@, cancelKey:%@", NSStringFromSelector(_cmd), @(flag), number);
}

@end
