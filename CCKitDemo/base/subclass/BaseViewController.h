//
//  UIBaseViewController.h
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+CCKit.h"
#import "UIColor+CCKit.h"
#import "CCKitMacro.h"

@interface BaseViewController : UIViewController

@property (nonatomic, assign) BOOL enableTap;

- (void)showMessage:(NSString *)message;

- (void)showLoadingMessage:(NSString *)message;
- (void)hideLoadingMessage;

- (void)showRightBarButtonItemWithName:(NSString *)rightItemName;

@end

@interface BaseViewController (need_override)

// called after `viewDidLoad`
- (void)initView;

- (void)tapClick:(UITapGestureRecognizer *)gr;

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem;

@end
