//
//  VCTransitionViewController.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "VCTransitionViewController.h"
#import "CustomNavigationChildViewController.h"
#import "SimpleNavigationDelegate.h"
#import "InteractiveNavigationDelegate.h"
#import "ImageTransitionViewController.h"

@interface VCTransitionViewController ()

@property (nonatomic) NSArray *arrayDelegate;

@property (nonatomic) SimpleNavigationDelegate *delegateSimple;
@property (nonatomic) InteractiveNavigationDelegate *delegateInteractive;

@end

@implementation VCTransitionViewController {
    NSArray *_arrayDelegate;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.delegate = nil;
    self.delegateSimple = nil;
    self.delegateInteractive = nil;
}

- (void)initView {
    self.arrayTitle = @[@"Custom NavigationController", @"Interactive NavigationController", @"Image Transition"];
    
    __weak typeof(self) wself = self;
    self.cellSelectedBlock = ^(NSIndexPath *path) {
        if (path.row == 0) {
            wself.delegateSimple = [SimpleNavigationDelegate new];
            wself.delegateSimple.navigationController = wself.navigationController;
            wself.navigationController.delegate = wself.delegateSimple;
            
            CustomNavigationChildViewController *vc = [[CustomNavigationChildViewController alloc] init];
            vc.enableTap = YES;
            [wself.navigationController pushViewController:vc animated:YES];
        } else if (path.row == 1) {
            wself.delegateInteractive = [[InteractiveNavigationDelegate alloc] initWithNavigationController:wself.navigationController];
            wself.navigationController.delegate = wself.delegateInteractive;
            
            CustomNavigationChildViewController *vc = [[CustomNavigationChildViewController alloc] init];
            vc.enableTap = YES;
            [wself.navigationController pushViewController:vc animated:YES];
        } else {
            ImageTransitionViewController *vc = [[ImageTransitionViewController alloc] init];
            [wself.navigationController pushViewController:vc animated:YES];
        }
    };
    
    [super initView];
}

@end
