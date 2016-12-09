//
//  NSUserDefaultsViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSUserDefaultsViewController.h"

@interface NSUserDefaultsViewController ()

@property (nonatomic) UISwitch *switchControl;

@end

@implementation NSUserDefaultsViewController

- (void)dealloc {
    exit(0);
}

- (void)initView {
    self.enableTap = YES;
    
    _switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:_switchControl];
    _switchControl.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    _switchControl.on = [self getUserBoolValue];
    [_switchControl addTarget:self action:@selector(switchControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    exit(-1);
}

- (void)switchControlValueChanged:(id)sender {
    [self setUserBoolValue:_switchControl.isOn];
}

- (BOOL)getUserBoolValue {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"boolValue"];
}

- (void)setUserBoolValue:(BOOL)b {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), @(b));
    
    [[NSUserDefaults standardUserDefaults] setBool:b forKey:@"boolValue"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
    
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    exit(0);
}

@end
