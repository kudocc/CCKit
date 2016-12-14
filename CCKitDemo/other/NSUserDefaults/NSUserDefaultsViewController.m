//
//  NSUserDefaultsViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSUserDefaultsViewController.h"
#import <objc/runtime.h>

@interface NSUserDefaults (test)

@end

@implementation NSUserDefaults (test)

+ (void)load {
    Method m1 = class_getInstanceMethod(self.class, NSSelectorFromString(@"synchronize"));
    if (!m1) {
        return;
    }
    Method m2 = class_getInstanceMethod(self.class, NSSelectorFromString(@"test_synchronize"));
    if (!m2) {
        return;
    }
    method_exchangeImplementations(m1, m2);
}

- (void)test_synchronize {
    [self test_synchronize];
    NSLog(@"call synchronize");
}

@end

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
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        exit(0);
//    });
    
    [[NSUserDefaults standardUserDefaults] synchronize];
//    exit(0);
}

@end
