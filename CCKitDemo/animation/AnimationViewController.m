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
#import "AnimationKeyboardViewController.h"

#import "JJViewController.h"

@implementation AnimationViewController

- (void)showBinaryUnsignedChar:(unsigned char)c {
    int i = 7;
    unsigned char mask = 0x1;
    do {
        unsigned char cc = (c>>i) & mask;
        if (cc == mask) {
            printf("1");
        } else {
            printf("0");
        }
        --i;
    } while (i >= 0);
}

- (void)showBinaryFloat:(float)f {
    unsigned char mem[4];
    memcpy(mem, &f, sizeof(f));
    int i = 3;
    do {
        [self showBinaryUnsignedChar:mem[i]];
        --i;
    } while (i >= 0);
    printf("\n");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"Implicity Animation", @"CABasicAnimation", @"CAKeyframeAnimation", @"CAAction", @"ShapeLayer Animation", @"Animation interaction with keyboard", @"JJ"];
    self.arrayClass = @[[ImplicityAnimationViewController class],
                        [CABasicAnimationTestViewController class],
                        [CAKeyframeViewController class],
                        [CAActionTestViewController class],
                        [CAShapeLayerTestViewController class],
                        [AnimationKeyboardViewController class],
                        [JJViewController class]];
    
    [self showBinaryUnsignedChar:1];
    printf("\n");
    [self showBinaryFloat:1];
    [self showBinaryFloat:2];
    [self showBinaryFloat:3];
    [self showBinaryFloat:3.0];
    float f0 = 10.0;
    float f1 = 0.3;
    [self showBinaryFloat:f0*f1];
}

@end
