//
//  ViewController.m
//  performance
//
//  Created by KudoCC on 16/1/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PerformanceViewController.h"
#import "PerformanceStoreViewController.h"
#import "ImageViewContainer.h"
#import "DrawViewContainer.h"
#import "PerformanceContainerViewController.h"

@interface PerformanceViewController ()

@end

@implementation PerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.arrayTitle = @[@"Performance Store",
                        @"Performance with container as UImageView",
                        @"Performance with container as UIView",
                        @"Container"];
    self.arrayClass = @[[PerformanceStoreViewController class],
                        [ImageViewContainer class],
                        [DrawViewContainer class],
                        [PerformanceContainerViewController class]
                        ];
}

@end
