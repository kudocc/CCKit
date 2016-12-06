//
//  UIDownloadTaskViewController.m
//  URLSessionTest
//
//  Created by KudoCC on 16/3/4.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIDownloadTaskViewController.h"

@interface UIDownloadTaskViewController () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic) UIButton *buttonPause;

@end

@implementation UIDownloadTaskViewController

- (void)dealloc {
    [_downloadTask removeObserver:self forKeyPath:@"state"];
}

- (void)initView {
    _buttonPause = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonPause.frame = CGRectMake(self.view.width/2-100.0/2, self.view.height/3, 100.0, 60.0);
    [_buttonPause setTitle:@"Start" forState:UIControlStateNormal];
    [_buttonPause setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonPause setBackgroundColor:[UIColor whiteColor]];
    [_buttonPause addTarget:self action:@selector(pauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonPause];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    
    // Test invalidate with two methods
//    [session invalidateAndCancel];
//    [session finishTasksAndInvalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _downloadTask && [keyPath isEqualToString:@"state"]) {
        NSString *title = @"";
        if (_downloadTask.state == NSURLSessionTaskStateRunning) {
            title = @"Pause";
        } else if (_downloadTask.state == NSURLSessionTaskStateSuspended) {
            title = @"Resume";
        } else if (_downloadTask.state == NSURLSessionTaskStateCanceling) {
            title = @"The task is canceling";
        } else {
            title = @"Finish";
        }
        [_buttonPause setTitle:title forState:UIControlStateNormal];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)pauseButtonPressed:(id)sender {
    if (!_downloadTask || (_downloadTask.state == NSURLSessionTaskStateCompleted && _resumeData)) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15.0;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                              delegate:self
                                                         delegateQueue:_operationQueue];
        // remove kvo
        [_downloadTask removeObserver:self forKeyPath:@"state"];
        if (!_downloadTask) {
            NSURL *urlFile = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/0c/25762/KugouMusicForMac.1395978517.dmg"];
            _downloadTask = [session downloadTaskWithURL:urlFile];
        } else {
            _downloadTask = [session downloadTaskWithResumeData:_resumeData];
        }
        [_downloadTask addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        [_downloadTask resume];
        return;
    }
    
    if (_downloadTask.state == NSURLSessionTaskStateRunning) {
        [_downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            _resumeData = [resumeData copy];
        }];
    } else if (_downloadTask.state == NSURLSessionTaskStateSuspended) {
        [_downloadTask resume];
    } else {
        NSLog(@"current state:%@", @(_downloadTask.state));
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler {
    NSLog(@"%@, responseHeader:%@", NSStringFromSelector(_cmd), response.allHeaderFields);
    
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
// needNewBodyStream:(void (^)(NSInputStream * __nullable bodyStream))completionHandler;

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//   didSendBodyData:(int64_t)bytesSent
//    totalBytesSent:(int64_t)totalBytesSent
//totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%@, error:%@", NSStringFromSelector(_cmd), error);
}

#pragma mark - NSURLSessionDownloadDelegate

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%@, download file at %@, response:%@", NSStringFromSelector(_cmd), location, downloadTask.response);
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%@, didWriteData:%lld, totalBytesWritten:%lld, totalBytesExpectedToWrite:%lld", NSStringFromSelector(_cmd), bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - NSURLSessionDataDelegate

/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 *
 * This method will not be called for background upload tasks (which cannot be converted to download tasks).
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    completionHandler(NSURLSessionResponseAllow);
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    completionHandler(proposedResponse);
}

@end
