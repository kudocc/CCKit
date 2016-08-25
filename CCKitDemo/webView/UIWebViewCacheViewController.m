//
//  UIWebViewCacheViewController.m
//  WebCache
//
//  Created by KudoCC on 15/9/20.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "UIWebViewCacheViewController.h"

@interface UIWebViewCacheViewController ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation UIWebViewCacheViewController

- (NSURLRequest *)request {
//    NSString *strURL = @"http://192.168.2.139:8080";
    NSString *strURL = @"http://www.baidu.com/";
    /*
    typedef NS_ENUM(NSUInteger, NSURLRequestCachePolicy)
    {
        NSURLRequestUseProtocolCachePolicy = 0,
        
        NSURLRequestReloadIgnoringLocalCacheData = 1,
        NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4, // Unimplemented
        NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
        
        NSURLRequestReturnCacheDataElseLoad = 2,
        NSURLRequestReturnCacheDataDontLoad = 3,
        
        NSURLRequestReloadRevalidatingCacheData = 5, // Unimplemented
    };
     */
    _request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    return _request;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(reload)];
    
    CGRect frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _webView = [[UIWebView alloc] initWithFrame:frame];
    [self.view addSubview:_webView];
}

- (void)reload {
    [_webView loadRequest:[self request]];
}

@end
