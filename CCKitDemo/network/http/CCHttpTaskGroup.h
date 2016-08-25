//
//  CCHttpTaskGroup.h
//  demo
//
//  Created by KudoCC on 16/5/23.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCHttpTaskOperation <NSObject>
- (void)cancel;
@end


@class CCHttpTask;
@protocol CCHttpTaskDelegate <NSObject>

@required
- (void)task:(CCHttpTask *)task didFinishWithResponseData:(NSDictionary *)response httpResponseStatus:(int)statusCode;
- (void)task:(CCHttpTask *)task didFailWithError:(NSError *)error;

@end


@interface CCHttpTask : NSObject <CCHttpTaskOperation>

/// task name, used when debug
@property (nonatomic, copy) NSString *taskName;

/// task identifier, used to identify a task
@property (nonatomic, readonly) NSString *taskIdentifier;

@property (nonatomic, copy) NSURL *url;

/// if post is YES, it is the parameters for contentType:application/x-www-form-urlencoded
/// else it is composed as parameter part of the url
@property (nonatomic, copy) NSDictionary *params;

/// default is YES
@property (nonatomic, assign) BOOL post;

@property (nonatomic, weak) id<CCHttpTaskDelegate> delegate;

@property (nonatomic, readonly) NSArray<CCHttpTask*> *dependencies;

/**
 Add dependency task, so self will execute after the task finishs.
 */
- (void)addDependencyTask:(CCHttpTask *)task;

/**
 if you use this method to start the task, the dependencies would be ignored.
 */
- (void)startTask;

@end


@protocol CCHttpTaskGroupDelegate;
@interface CCHttpTaskGroup : NSObject <CCHttpTaskOperation>

@property (nonatomic, weak) id<CCHttpTaskGroupDelegate> delegate;

- (void)addTask:(CCHttpTask *)task;

- (void)startTaskGroup;

@end


@protocol CCHttpTaskGroupDelegate <NSObject>

@required
- (void)groupTask:(CCHttpTaskGroup *)groupTask
    taskDidFinish:(CCHttpTask *)task
     responseData:(NSDictionary *)response httpResponseStatus:(int)statusCode;

- (void)groupTask:(CCHttpTaskGroup *)groupTask taskDidFail:(CCHttpTask *)task error:(NSError *)error;

@optional
- (void)groupTaskWillStart:(CCHttpTaskGroup *)groupTask;
- (void)groupTaskDidEnd:(CCHttpTaskGroup *)groupTask;

/// invoke just before the task starts, this is the last chance for you to modify the property of task
- (void)taskWillStart:(CCHttpTask *)task inGroup:(CCHttpTaskGroup *)groupTask;

@end