//
//  VCTransitionViewController.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "VCTransitionViewController.h"
#import "TransitionFakePushPopViewController.h"
#import "TransitionFakeInteractivePushPopViewController.h"

@interface VCTransitionViewController ()

@end

@implementation VCTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayTitle = @[@"Present&Dismiss with Push&Pop", @"Dismiss with interactive pop"];
    self.arrayClass = @[[TransitionFakePushPopViewController class],
                        [TransitionFakeInteractivePushPopViewController class]];
}

@end
