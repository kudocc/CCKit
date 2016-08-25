//
//  ViewController.m
//  performance
//
//  Created by KudoCC on 16/1/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PerformanceViewController.h"
#import "ImageViewContainer.h"
#import "DrawViewContainer.h"

@interface PerformanceViewController ()

@end

@implementation PerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.arrayTitle = @[@"Performance with container as UImageView", @"Performance with container as UIView"];
    self.arrayClass = @[[ImageViewContainer class], [DrawViewContainer class]];
}

@end
