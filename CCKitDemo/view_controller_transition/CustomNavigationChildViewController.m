//
//  CustomNavigationChildViewController.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CustomNavigationChildViewController.h"

@implementation CustomNavigationChildViewController

- (void)initView {
    int red = arc4random_uniform(255);
    int green = arc4random_uniform(255);
    int blue = arc4random_uniform(255);
    self.view.backgroundColor = [UIColor cc_colorWithRed:red green:green blue:blue];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    CustomNavigationChildViewController *vc = [[CustomNavigationChildViewController alloc] init];
    vc.enableTap = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end