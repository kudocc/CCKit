//
//  HttpViewController.m
//  demo
//
//  Created by KudoCC on 16/5/24.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HttpViewController.h"
#import "HttpAsyncRequestsViewController.h"
#import "HttpChainedRequestsViewController.h"
#import "HttpComplexRequestsViewController.h"

@interface HttpViewController ()

@end

@implementation HttpViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"3 Async request", @"3 chained request", @"complex dependency request"];
    self.arrayClass = @[[HttpAsyncRequestsViewController class],
                        [HttpChainedRequestsViewController class],
                        [HttpComplexRequestsViewController class]];
}

@end
