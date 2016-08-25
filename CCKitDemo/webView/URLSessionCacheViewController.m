//
//  URLSessionCacheViewController.m
//  WebCache
//
//  Created by KudoCC on 15/9/20.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "URLSessionCacheViewController.h"

@interface URLSessionCacheViewController ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation URLSessionCacheViewController

- (NSURLRequest *)request {
//    NSString *strURL = @"http://www.baidu.com/";
    NSString *strURL = @"http://192.168.2.139:8080";
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
    
//    NSString *pathToCache = @"urlsessioncache";
//    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:10*1024*1024 diskCapacity:10*1024*1024 diskPath:pathToCache];
    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    defaultSessionConfiguration.URLCache = urlCache;
//    NSURLSessionConfiguration *ephemeralSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
    _dataTask = [session dataTaskWithRequest:[self request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"dataLen:%lu", (unsigned long)[data length]);
    }];
    [_dataTask resume];
}

- (void)reload {
    NSURLSession *session = [NSURLSession sharedSession];
    _dataTask = [session dataTaskWithRequest:[self request] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"dataLen:%lu", (unsigned long)[data length]);
    }];
    [_dataTask resume];
}

@end
