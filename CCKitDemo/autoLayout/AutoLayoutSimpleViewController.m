//
//  AutoLayoutSimpleViewController.m
//  demo
//
//  Created by KudoCC on 16/8/5.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AutoLayoutSimpleViewController.h"

@interface AutoLayoutSimpleViewController ()

@end

@implementation AutoLayoutSimpleViewController

- (void)initView {
    [super initView];
    
    UILabel *labelTitle = [[UILabel alloc] init];
    labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
    labelTitle.text = @"text";
    [self.view addSubview:labelTitle];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:64];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:40];
    [self.view addConstraints:@[left, width, top, height]];
}

@end
