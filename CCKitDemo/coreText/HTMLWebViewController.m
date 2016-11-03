//
//  HTMLWebViewController.m
//  demo
//
//  Created by KudoCC on 16/6/14.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HTMLWebViewController.h"

@implementation HTMLWebViewController

- (void)initView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) configuration:configuration];
    [self.view addSubview:_webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"html_parser" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];
}

@end
