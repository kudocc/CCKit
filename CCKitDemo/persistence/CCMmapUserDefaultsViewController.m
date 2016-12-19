//
//  CCMmapUserDefaultsViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCMmapUserDefaultsViewController.h"
#import "CCMmapUserSettings.h"

@interface CCMmapUserDefaultsViewController () <UITextFieldDelegate>

@property (nonatomic) UITextField *textField;
@property (nonatomic) UISwitch *sc0;
@property (nonatomic) UISwitch *sc1;
@property (nonatomic) UISwitch *sc2;
@property (nonatomic) UISwitch *sc3;

@end

@implementation CCMmapUserDefaultsViewController

- (void)initView {
    [self showRightBarButtonItemWithName:@"exit"];
    
    [CCMmapUserSettings sharedUserSettings].automaticSynchronize = YES;
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:@"999"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeightNoTop)];
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    
    CGFloat x = 100;
    CGFloat y = 20;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 50.0, ScreenWidth-30, 40.0)];
    [scrollView addSubview:_textField];
    _textField.text = [[CCMmapUserSettings sharedUserSettings] stringForKey:@"text"];
    _textField.delegate = self;
    _textField.layer.borderColor = [UIColor blueColor].CGColor;
    _textField.layer.borderWidth = 1.0;
    
    y = _textField.bottom + 20.0;
    
    _sc0 = [[UISwitch alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
    _sc0.tag = 0;
    _sc0.on = [self getUserBoolValue:_sc0.tag];
    [_sc0 addTarget:self action:@selector(switchControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:_sc0];
    
    y = _sc0.bottom + 20.0;
    _sc1 = [[UISwitch alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
    _sc1.tag = 1;
    _sc1.on = [self getUserBoolValue:_sc1.tag];
    [_sc1 addTarget:self action:@selector(switchControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:_sc1];
    
    y = _sc1.bottom + 20.0;
    _sc2 = [[UISwitch alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
    _sc2.tag = 2;
    _sc2.on = [self getUserBoolValue:_sc2.tag];
    [_sc2 addTarget:self action:@selector(switchControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:_sc2];
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, _sc2.bottom);
    scrollView.alwaysBounceVertical = YES;
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    exit(-1);
}

- (void)switchControlValueChanged:(UISwitch *)sender {
    [self setUserBoolValue:sender.isOn forIndex:sender.tag];
}

- (BOOL)getUserBoolValue:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"bool%@", @(index)];
    return [[CCMmapUserSettings sharedUserSettings] boolForKey:key];
}

- (void)setUserBoolValue:(BOOL)b forIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"bool%@", @(index)];
    [[CCMmapUserSettings sharedUserSettings] setBool:b forKey:key];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [[CCMmapUserSettings sharedUserSettings] setObject:textField.text forKey:@"text"];
}

@end
