//
//  OtherViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "OtherViewController.h"
#import "KVOViewController.h"
#import "ScaleScrollViewController.h"
#import "PresentViewController.h"

@implementation OtherViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"KVO", @"Scroll", @"Present"];
    self.arrayClass = @[[KVOViewController class], [ScaleScrollViewController class], [PresentViewController class]];
}

@end
