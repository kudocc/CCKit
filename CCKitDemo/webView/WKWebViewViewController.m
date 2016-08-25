//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by KudoCC on 15/9/15.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "WKWebViewViewController.h"
#import <WebKit/WebKit.h>

static void *WebViewControllerObservationContext = &WebViewControllerObservationContext;

@interface WKWebViewViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation WKWebViewViewController

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"loading" context:WebViewControllerObservationContext];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress" context:WebViewControllerObservationContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    [self.view addSubview:_webView];
    
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.navigationDelegate = self;
    [_webView addObserver:self forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:WebViewControllerObservationContext];
    [_webView addObserver:self forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:WebViewControllerObservationContext];
    
    NSString *strURL = @"http://192.168.2.139:8080";
//    NSString *strURL = @"http://www.baidu.com/";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    [_webView loadRequest:request];
    
    [self showLoadingView];
    
    /*
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ViewController *vc = [[ViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    });*/
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == WebViewControllerObservationContext) {
        if ([keyPath isEqualToString:@"loading"]) {
            BOOL loading = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            if (loading) {
                [self showLoadingView];
            } else {
                [self dismissLoadingView];
            }
        } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
            NSLog(@"load progress:%@", [change objectForKey:NSKeyValueChangeNewKey]);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%@, url:%@, type:%ld", NSStringFromSelector(_cmd), navigationAction.request.URL, (long)navigationAction.navigationType);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), navigation);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), navigation);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), navigation);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), navigation);
}

#pragma mark -

- (void)showLoadingView {
    if (!_indicator) {
//        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(roundf((self.view.frame.size.width - 50) / 2), roundf((self.view.frame.size.height - 50) / 2),50,50)];
        [self.view addSubview:_indicator];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _indicator.center = _webView.center;
    }
    if (![_indicator isAnimating]) {
        [_indicator startAnimating];
    }
}

- (void)dismissLoadingView {
    if ([_indicator isAnimating]) {
        [_indicator stopAnimating];
    }
}

@end
