//
//  HttpComplexRequestsViewController.m
//  demo
//
//  Created by KudoCC on 16/5/24.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HttpComplexRequestsViewController.h"
#import "CCHttpTaskGroup.h"

@interface HttpComplexRequestsViewController () <CCHttpTaskGroupDelegate> {
    CCHttpTaskGroup *_group;
    
    CCHttpTask *taskCancel;
}

@end

/**
          Task1 -> Task2 -> Task3
  
 Task4 -> Task5 -> Task2
 
          Task5 -> Task6
 */
@implementation HttpComplexRequestsViewController

- (void)initView {
    NSURL *url = [NSURL URLWithString:@"/2.2/users/1079899?page=1&pagesize=10&fromdate=1460332800&todate=1464048000&order=desc&min=1&max=10&sort=reputation&site=stackoverflow" relativeToURL:[NSURL URLWithString:@"https://api.stackexchange.com"]];
    NSLog(@"url.baseURL %@", url.baseURL);
    
    CCHttpTask *task1 = [[CCHttpTask alloc] init];
    task1.url = url;
    task1.post = NO;
    task1.taskName = @"task1";
    
    CCHttpTask *task2 = [[CCHttpTask alloc] init];
    task2.url = url;
    task2.post = NO;
    task2.taskName = @"task2";
    
    CCHttpTask *task3 = [[CCHttpTask alloc] init];
    task3.url = url;
    task3.post = NO;
    task3.taskName = @"task3";
    
    CCHttpTask *task4 = [[CCHttpTask alloc] init];
    task4.url = url;
    task4.post = NO;
    task4.taskName = @"task4";
    
    CCHttpTask *task5 = [[CCHttpTask alloc] init];
    task5.url = url;
    task5.post = NO;
    task5.taskName = @"task5";
    
    CCHttpTask *task6 = [[CCHttpTask alloc] init];
    task6.url = url;
    task6.post = NO;
    task6.taskName = @"task6";
    
    [task6 addDependencyTask:task5];
    [task5 addDependencyTask:task4];
    [task3 addDependencyTask:task2];
    [task2 addDependencyTask:task5];
    [task2 addDependencyTask:task1];
    
    _group = [[CCHttpTaskGroup alloc] init];
    [_group addTask:task1];
    [_group addTask:task2];
    [_group addTask:task3];
    [_group addTask:task4];
    [_group addTask:task5];
    [_group addTask:task6];
    _group.delegate = self;
    [_group startTaskGroup];
    
    taskCancel = task2;
}

#pragma mark - CCHttpTaskGroupDelegate

- (void)groupTask:(CCHttpTaskGroup *)groupTask
    taskDidFinish:(CCHttpTask *)task
     responseData:(NSDictionary *)response httpResponseStatus:(int)statusCode {
    NSLog(@"task:%@, %@", task, NSStringFromSelector(_cmd));
    
    [taskCancel cancel];
}

- (void)groupTask:(CCHttpTaskGroup *)groupTask taskDidFail:(CCHttpTask *)task error:(NSError *)error {
    NSLog(@"task:%@, %@", task, NSStringFromSelector(_cmd));
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
    NSLog(@"task:%@, %@", task, NSStringFromSelector(_cmd));
}

@end