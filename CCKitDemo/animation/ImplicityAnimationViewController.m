//
//  ImplicityAnimationViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImplicityAnimationViewController.h"

// http://stackoverflow.com/a/21240400/1079899

@implementation ImplicityAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.enableTap = YES;
    
    _layer = [[CALayer alloc] init] ;
    UIImage *image = [UIImage imageNamed:@"conan1"];
    _layer.frame = CGRectMake(10.0, 64.0, image.size.width, image.size.height);
    _layer.contents = (__bridge id)image.CGImage ;
    [self.view.layer addSublayer:_layer] ;
    
    _layer1 = [[CALayer alloc] init] ;
    _layer1.frame = CGRectMake(210.0, 64.0, image.size.width, image.size.height);
    _layer1.contents = (__bridge id)image.CGImage ;
    [self.view.layer addSublayer:_layer1] ;
    
    _viewTest = [[UIView alloc] initWithFrame:CGRectMake(10, 200, image.size.width, image.size.height)];
    _viewTest.layer.contents = (__bridge id)image.CGImage;
    [self.view addSubview:_viewTest];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0];
    _layer.opacity = 0.1;
    [CATransaction commit];
    
    // disable the implicity animate
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _layer1.opacity = 0.1;
    [CATransaction commit];
    
    // if a layer belongs to layer-backed view, must use UIView block to animate
    [UIView animateWithDuration:2.0 animations:^{
        _viewTest.layer.opacity = 0.1;
    }];
}

@end
