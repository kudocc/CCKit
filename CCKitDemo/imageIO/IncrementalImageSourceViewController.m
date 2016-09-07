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
    operationQueue.maxConcurrentOperationCount = 1;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
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
    NSDictionary *options = @{(__bridge id)kCGImageSourceShouldCache:@NO};
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageRef) {
        NSLog(@"%p, %ld", imageRef, CFGetRetainCount(imageRef));
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        NSLog(@"%p, %ld", image.CGImage, CFGetRetainCount(imageRef));
     
#if 0
        // debug navigator的内存略有变化
        CGSize size = image.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = returnImage;
        });
#else
        // debug navigator的内存会很快升高，就像图片的内存不被释放一样
        // heap allocation和VM都升高的很快，并且退出不会下降，VM的升高主要是在ImageIO ImageIO_jpeg_data那里
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
#endif
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