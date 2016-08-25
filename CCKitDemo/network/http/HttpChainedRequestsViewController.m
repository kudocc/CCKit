//
//  HttpChainedRequestsViewController.m
//  demo
//
//  Created by KudoCC on 16/5/24.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HttpChainedRequestsViewController.h"
#import "CCHttpTaskGroup.h"

@interface HttpChainedRequestsViewController () <CCHttpTaskGroupDelegate> {
    CCHttpTaskGroup *_group;
}

@end

@implementation HttpChainedRequestsViewController

- (void)initView {
    NSURL *url = [NSURL URLWithString:@"/2.2/users/1079899?page=1&pagesize=10&fromdate=1460332800&todate=1464048000&order=desc&min=1&max=10&sort=reputation&site=stackoverflow" relativeToURL:[NSURL URLWithString:@"https://api.stackexchange.com"]];
    NSLog(@"url.baseURL %@", url.baseURL);
    
    CCHttpTask *task1 = [[CCHttpTask alloc] init];
    task1.url = url;
    task1.post = NO;
    
    CCHttpTask *task2 = [[CCHttpTask alloc] init];
    task2.url = url;
    task2.post = NO;
    
    CCHttpTask *task3 = [[CCHttpTask alloc] init];
    task3.url = url;
    task3.post = NO;
    
    [task3 addDependencyTask:task2];
    [task2 addDependencyTask:task1];
    
    _group = [[CCHttpTaskGroup alloc] init];
    [_group addTask:task1];
    [_group addTask:task2];
    [_group addTask:task3];
    _group.delegate = self;
    [_group startTaskGroup];
}

#pragma mark - CCHttpTaskGroupDelegate

- (void)groupTask:(CCHttpTaskGroup *)groupTask
    taskDidFinish:(CCHttpTask *)task
     responseData:(NSDictionary *)response httpResponseStatus:(int)statusCode {
    NSLog(@"%@, data:%@", NSStringFromSelector(_cmd), response);
}

- (void)groupTask:(CCHttpTaskGroup *)groupTask taskDidFail:(CCHttpTask *)task error:(NSError *)error {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)groupTaskWillStart:(CCHttpTaskGroup *)groupTask {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self showLoadingMessage:@"requesting"];
}

- (void)groupTaskDidEnd:(CCHttpTaskGroup *)groupTask {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self hideLoadingMessage];
}

- (void)taskWillStart:(CCHttpTask *)task inGroup:(CCHttpTaskGroup *)groupTask {
    NSLog(@"task:%@, %@", [task taskIdentifier], NSStringFromSelector(_cmd));
}

@end
