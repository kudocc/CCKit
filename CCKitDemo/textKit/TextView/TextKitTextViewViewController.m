//
//  TextKitTextViewViewController.m
//  CCKitDemo
//
//  Created by rui yuan on 2017/12/20.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKitTextViewViewController.h"
#import "TextKitTextViewChildViewController.h"

@interface TextKitTextViewViewController ()

@property (nonatomic) TextKitTextViewChildViewController *child;

@end

@implementation TextKitTextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.child = [[UIStoryboard storyboardWithName:@"TextKit" bundle:nil] instantiateViewControllerWithIdentifier:@"child"];
    [self.view addSubview:self.child.view];
    
    [self.view.topAnchor constraintEqualToAnchor:self.child.view.topAnchor].active = YES;
    [self.view.bottomAnchor constraintEqualToAnchor:self.child.view.bottomAnchor].active = YES;
    [self.view.trailingAnchor constraintEqualToAnchor:self.child.view.trailingAnchor].active = YES;
    [self.view.leadingAnchor constraintEqualToAnchor:self.child.view.leadingAnchor].active = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
