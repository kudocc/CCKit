//
//  CAKeyframeViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CAKeyframeViewController.h"

@interface CAKeyframeViewController ()

@property (nonatomic, strong) CALayer *layer ;

@end

@implementation CAKeyframeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.enableTap = YES;
    
    _layer = [[CALayer alloc] init] ;
    UIImage *image = [UIImage imageNamed:@"conan1"];
    _layer.frame = CGRectMake(10.0, 64.0, image.size.width, image.size.height);
    _layer.contents = (__bridge id)image.CGImage;
    [self.view.layer addSublayer:_layer];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 200);
    CGPathAddCurveToPoint(path, NULL, 100, 100, 200, self.view.bounds.size.height, self.view.bounds.size.width, 200);
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyframeAnimation.path = path;
    keyframeAnimation.duration = 5.0;
    keyframeAnimation.calculationMode = kCAAnimationLinear;
    keyframeAnimation.keyTimes = @[@0, @0.5, @1];
    keyframeAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_layer addAnimation:keyframeAnimation forKey:@"position"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _layer.position = CGPathGetCurrentPoint(path);
    [CATransaction commit];
    
    CGPathRelease(path);
}

@end
