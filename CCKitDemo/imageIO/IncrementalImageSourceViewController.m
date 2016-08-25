//
//  IncrementalImageSourceViewController.m
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "IncrementalImageSourceViewController.h"
#import <ImageIO/ImageIO.h>

@implementation IncrementalImageSourceViewController {
    CGImageSourceRef imageSource;
    UIImageView *imageView;
    
    NSOperationQueue *operationQueue;
    NSURLSessionDataTask *dataTask;
    NSMutableData *mutableData;
    NSUInteger expectedLength;
}

- (void)dealloc {
    if (imageSource) {
        CFRelease(imageSource);
    }
}

- (void)initView {
    imageSource = CGImageSourceCreateIncremental(NULL);
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    operationQueue = [[NSOperationQueue alloc] init];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:operationQueue];
    
    // http://images.ali213.net/picfile/pic/2013/03/01/927_66.jpg
    NSString *strUrl = @"http://img4.duitang.com/uploads/item/201407/17/20140717093953_wQjyu.jpeg";
    NSURL *urlFile = [NSURL URLWithString:strUrl];
    dataTask = [session dataTaskWithURL:urlFile];
    [dataTask resume];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"%@, error:%@", NSStringFromSelector(_cmd), error);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%@, error:%@", NSStringFromSelector(_cmd), error);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    mutableData = [[NSMutableData alloc] init];
    expectedLength = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [mutableData appendData:data];
    NSLog(@"expectedLen:%lu, %lu", (unsigned long)expectedLength, (unsigned long)[mutableData length]);
    
    NSData *dataImage = [mutableData copy];
    CGImageSourceUpdateData(imageSource, (__bridge CFDataRef)dataImage, expectedLength <= [dataImage length]);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    if (imageRef) {
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // prevent from caching the image
    completionHandler(nil);
}

@end