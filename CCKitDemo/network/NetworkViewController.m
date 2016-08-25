//
//  NetworkViewController.m
//  demo
//
//  Created by KudoCC on 16/5/24.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NetworkViewController.h"
#import "HttpViewController.h"

@interface NetworkViewController ()

@end

@implementation NetworkViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"HTTP"];
    self.arrayClass = @[[HttpViewController class]];
}

@end
