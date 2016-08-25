//
//  ViewController.m
//  URLSessionTest
//
//  Created by KudoCC on 16/3/4.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UrlSessionViewController.h"
#import "DataTaskBasicAuthViewController.h"
#import "DataTaskHttpsServerAuthViewController.h"
#import "UIDownloadTaskViewController.h"

@implementation UrlSessionViewController

- (void)initView {
    self.arrayTitle = @[@"Basic Authentication", @"HTTPS", @"Test download task"];
    self.arrayClass = @[[DataTaskBasicAuthViewController class],
                        [DataTaskHttpsServerAuthViewController class],
                        [UIDownloadTaskViewController class]];
}

@end
