//
//  OtherViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "OtherViewController.h"
#import "KVOViewController.h"
#import "CCMmapUserDefaultsViewController.h"

@implementation OtherViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"KVO", @"CCMmapUserSettings test"];
    self.arrayClass = @[[KVOViewController class],
                        [CCMmapUserDefaultsViewController class]];
}

@end
