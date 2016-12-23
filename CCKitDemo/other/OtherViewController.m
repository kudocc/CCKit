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

@implementation OtherViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"KVO", @"Scroll"];
    self.arrayClass = @[[KVOViewController class], [ScaleScrollViewController class]];
}

@end
