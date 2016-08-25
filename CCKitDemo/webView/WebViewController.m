//
//  WebViewController.m
//  demo
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "WebViewController.h"
#import "UIWebViewViewController.h"
#import "WKWebViewViewController.h"
#import "URLSessionCacheViewController.h"
#import "UIWebViewCacheViewController.h"

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayTitle = @[@"UIWebViewController", @"WKWebViewController", @"URLSessionCache", @"UIWebViewCache"];
    self.arrayClass = @[[UIWebViewViewController class],
                        [WKWebViewViewController class],
                        [URLSessionCacheViewController class],
                        [UIWebViewCacheViewController class]];
}

@end
