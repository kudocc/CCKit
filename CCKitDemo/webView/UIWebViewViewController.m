//
//  ViewController.m
//  UIWebViewDemo
//
//  Created by KudoCC on 15/9/18.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "UIWebViewViewController.h"

@interface UIWebViewViewController () <UIWebViewDelegate>

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation UIWebViewViewController

- (NSURLRequest *)request {
//    NSString *strURL = @"http://192.168.2.139:8080";
    NSString *strURL = @"http://www.baidu.com";
    _request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    return _request;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

#if 1
    CGRect frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [_webView loadRequest:[self request]];
#else
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTask = [session dataTaskWithRequest:[self request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"dataLen:%lu", (unsigned long)[data length]);
    }];
    [_dataTask resume];
#endif
    
    UIButton *buttonReload = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonReload];
    buttonReload.frame = CGRectMake(0.0, 0.0, 100.0, 30.0);
    buttonReload.center = self.view.center;
    [buttonReload setTitle:@"reload" forState:UIControlStateNormal];
    buttonReload.backgroundColor = [UIColor yellowColor];
    [buttonReload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonReload addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
}

- (void)goBack:(id)sender {
    if ([_webView canGoBack]) {
        [_webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)reload:(id)sender {
#if 1
//    [_webView reload];
    [_webView loadRequest:[self request]];
#else
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTask = [session dataTaskWithRequest:[self request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"dataLen:%lu", (unsigned long)[data length]);
    }];
    [_dataTask resume];
#endif
}

#pragma mark - 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), request.URL.absoluteString);
    return YES;
}

@end
