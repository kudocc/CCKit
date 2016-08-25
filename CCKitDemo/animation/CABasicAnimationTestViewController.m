//
//  CABasicAnimationTestViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "CABasicAnimationTestViewController.h"

@interface CABasicAnimationTestViewController ()

@property (nonatomic, strong) CALayer *layer ;

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
//    _layer.delegate = self;
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    CGPoint p2 = CGPointMake(300.0, 300.0);
    CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAni.fromValue = [NSValue valueWithCGPoint:_layer.position];
    basicAni.toValue = [NSValue valueWithCGPoint:p2];
    basicAni.duration = 1.0;
    basicAni.fillMode = kCAFillModeBackwards;
    [_layer addAnimation:basicAni forKey:@"position"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _layer.position = p2;
    [CATransaction commit];
}

//- (id<CAAction>)actionForLayer:(CALayer *)theLayer
//                        forKey:(NSString *)theKey
//{
//    if ([theKey isEqualToString:@"position"]) {
//        return [NSNull null];
//    }
//    return nil;
//}


@end
