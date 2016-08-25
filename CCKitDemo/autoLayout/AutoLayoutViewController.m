//
//  AutoLayoutViewController.m
//  demo
//
//  Created by KudoCC on 16/8/5.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AutoLayoutViewController.h"
#import "AutoLayoutSimpleViewController.h"

@interface AutoLayoutViewController ()

@end

@implementation AutoLayoutViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Simple"];
    self.arrayClass = @[[AutoLayoutSimpleViewController class]];
}

@end
