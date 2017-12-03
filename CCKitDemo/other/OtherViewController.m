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
#import "ContactViewController.h"

@implementation OtherViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Contact", @"KVO", @"Scroll", @"Present"];
    self.arrayClass = @[[ContactViewController class], [KVOViewController class], [ScaleScrollViewController class], [PresentViewController class]];
}

@end
