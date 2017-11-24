//
//  PresentTestViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/9/27.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "PresentTestViewController.h"
#import "MDLMenuLabel.h"

@interface PresentTestViewController ()

@property UIViewController *useToDismiss;

@property (nonatomic) MDLMenuLabel *label;

@end

@implementation PresentTestViewController

- (void)initView {
    if (self.presentingViewController) {
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"left" style:UIBarButtonItemStyleDone target:self action:@selector(leftClick)];
        self.navigationItem.leftBarButtonItem = left;
        int f = arc4random_uniform(255);
        self.view.backgroundColor = [UIColor colorWithRed:1 green:f/255.0 blue:f/255.0 alpha:1];
    } else {
        self.view.backgroundColor = [UIColor redColor];
    }
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"right" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick)];
    self.navigationItem.rightBarButtonItem = right;
    
    NSLog(@"%@", @(self.modalPresentationStyle));
    
    self.label = [[MDLMenuLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/4, 100, self.view.bounds.size.width/2, 30)];
    self.label.selectedBackgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    self.label.text = self.name;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor blackColor];
    [self.view addSubview:self.label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Present a new vc" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(self.view.bounds.size.width/4, 200, self.view.bounds.size.width/2, 100)];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)leftClick {
    [self.label forceShowMenu];
    
    
//    NSLog(@"%@", self.presentingViewController);
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    /*
    UIViewController *v = self.presentingViewController;
    while (v.presentingViewController) {
        v = v.presentingViewController;
    }
    [v dismissViewControllerAnimated:YES completion:nil];
     */
}

- (void)rightClick {
    NSLog(@"name:%@, ing:%@, ed:%@, nav:%@", self.name, self.presentingViewController, self.presentedViewController, self.navigationController);
}

- (void)buttonPressed:(id)sender {
    PresentTestViewController *t = [[PresentTestViewController alloc] init];
    t.useToDismiss = self;
    t.modalPresentationStyle = UIModalPresentationOverFullScreen;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:t];
    NSTimeInterval inter = [[NSDate date] timeIntervalSince1970];
    t.name = [NSString stringWithFormat:@"%f", inter];
    NSLog(@"before present name:%@, ing:%@, ed:%@", self.name, self.presentingViewController, self.presentedViewController);
    [self presentViewController:nav animated:YES completion:^{
        NSLog(@"after present name:%@, ing:%@, ed:%@", self.name, self.presentingViewController, self.presentedViewController);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PresentTestViewController *t = [[PresentTestViewController alloc] init];
        t.useToDismiss = self;
        t.modalPresentationStyle = UIModalPresentationOverFullScreen;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:t];
        NSTimeInterval inter = [[NSDate date] timeIntervalSince1970];
        t.name = [NSString stringWithFormat:@"%f", inter];
        NSLog(@"before present name:%@, ing:%@, ed:%@", self.name, self.presentingViewController, self.presentedViewController);
        [self presentViewController:nav animated:YES completion:^{
            NSLog(@"after present name:%@, ing:%@, ed:%@", self.name, self.presentingViewController, self.presentedViewController);
        }];
    });
}

@end
