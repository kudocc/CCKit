//
//  UIBaseViewController.m
//  AnimationDemo
//
//  Created by KudoCC on 15/4/27.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"
#import <MBProgressHUD.h>

@interface BaseViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGR;

@property (nonatomic, strong) CALayer *layerTips;


@property (nonatomic, strong) MBProgressHUD *hudText;
@property (nonatomic, strong) MBProgressHUD *hudLoading;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor cc_colorWithRed:239 green:239 blue:244];
    self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    self.title = NSStringFromClass(self.class);
    
    NSString *string = @"Tap";
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName:[UIColor blueColor]};
    CGRect bounding = [string boundingRectWithSize:CGSizeMake(1024, 30.0) options:0 attributes:attribute context:nil];
    CGSize size = CGSizeMake(ceil(bounding.size.width), ceil(bounding.size.height));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawAtPoint:CGPointMake(0, 0) withAttributes:attribute];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _layerTips = [[CALayer alloc] init];
    
    _layerTips.contents = (__bridge id)image.CGImage;
    [self.view.layer addSublayer:_layerTips];
    _layerTips.frame = CGRectMake(0, 0, size.width, size.height);
    _layerTips.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    [self initView];
}

- (void)setEnableTap:(BOOL)enableTap {
    _enableTap = enableTap;
    if (_enableTap) {
        if (!_tapGR) {
            _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        }
        [self.view addGestureRecognizer:_tapGR];
    } else {
        if (_tapGR) {
            [self.view removeGestureRecognizer:_tapGR];
        }
    }
}

- (void)showRightBarButtonItemWithName:(NSString *)rightItemName {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightItemName style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick:)];
}

#pragma mark - show text tips

- (MBProgressHUD *)hudText {
    if (!_hudText) {
        _hudText = [[MBProgressHUD alloc] initWithView:self.view];
        _hudText.mode = MBProgressHUDModeText;
        [self.view addSubview:_hudText];
    }
    return _hudText;
}

- (void)showMessage:(NSString *)message {
    [self showMessage:message detailMessage:nil];
}

- (void)showMessage:(NSString *)message detailMessage:(NSString *)detailMessage {
    self.hudText.detailsLabelText = detailMessage;
    self.hudText.labelText = message;
    [self.hudText show:YES];
    [self.hudText hide:YES afterDelay:1.5];
}

- (MBProgressHUD *)hudLoading {
    if (!_hudLoading) {
        _hudLoading = [[MBProgressHUD alloc] initWithView:self.view];
        _hudLoading.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview:_hudLoading];
    }
    return _hudLoading;
}

- (void)showLoadingMessage:(NSString *)message {
    self.hudLoading.labelText = message;
    [self.hudLoading show:YES];
}

- (void)hideLoadingMessage {
    [self.hudLoading hide:YES];
}

@end

@implementation BaseViewController (need_override)

- (void)initView {
    
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    
}

@end
