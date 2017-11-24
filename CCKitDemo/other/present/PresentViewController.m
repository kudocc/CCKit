//
//  PresentViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/9/27.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "PresentViewController.h"
#import "PresentTestViewController.h"

@interface PresentViewController ()

@end

@implementation PresentViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Present Test"];
    self.arrayClass = @[[PresentTestViewController class]];
}

@end
