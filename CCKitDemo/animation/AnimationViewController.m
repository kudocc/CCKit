//
//  ViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AnimationViewController.h"
#import "ImplicityAnimationViewController.h"
#import "CABasicAnimationTestViewController.h"
#import "CAKeyframeViewController.h"
#import "CAActionTestViewController.h"
#import "CAShapeLayerTestViewController.h"

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"Implicity Animation", @"CABasicAnimation", @"CAKeyframeAnimation", @"CAAction", @"ShapeLayer Animation"];
    self.arrayClass = @[[ImplicityAnimationViewController class],
                    [CABasicAnimationTestViewController class],
                    [CAKeyframeViewController class],
                    [CAActionTestViewController class],
                    [CAShapeLayerTestViewController class]];
}

@end
