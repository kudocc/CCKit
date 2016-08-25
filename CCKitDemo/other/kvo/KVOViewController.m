//
//  KVOViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "KVOViewController.h"
#import "KVOBaseViewController.h"
#import "KVOSubViewController.h"

@implementation KVOViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Key Value Oberving"];
    self.arrayClass = @[[KVOSubViewController class]];
}

@end
