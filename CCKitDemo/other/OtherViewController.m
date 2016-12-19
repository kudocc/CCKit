//
//  OtherViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "OtherViewController.h"
#import "KVOViewController.h"

@implementation OtherViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"KVO"];
    self.arrayClass = @[[KVOViewController class]];
}

@end
