//
//  ImageDestinationViewController.m
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageDestinationViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImage+CCKit.h"
#import "ImagePickerViewControllerHelper.h"

// save meta data to photosalbum in iOS
// http://stackoverflow.com/questions/7965299/write-uiimage-along-with-metadata-exif-gps-tiff-in-iphones-photo-library

@implementation ImageDestinationViewController {
    UIScrollView *scrollView;
}

- (void)addImageToViewWithURL:(NSURL *)url {
    CGFloat x = 0;
    CGFloat y = scrollView.contentSize.height;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (imageSource) {
        CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
        NSDictionary *dictProperty = (__bridge_transfer id)property;
        NSLog(@"container property:%@", dictProperty);
        
        property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        dictProperty = (__bridge_transfer id)property;
        NSLog(@"image at index 0 property:%@", dictProperty);
        
        UIImageOrientation orientation = UIImageOrientationUp;
        int exifOrientation;
        CFTypeRef val = CFDictionaryGetValue(property, kCGImagePropertyOrientation);
        if (val) {
            CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
            orientation = [UIImage cc_exifOrientationToiOSOrientation:exifOrientation];
        }
        
        size_t count = CGImageSourceGetCount(imageSource);
        NSLog(@"image count:%zu", count);
        
        for (size_t i = 0; i < count; ++i) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:orientation];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                [scrollView addSubview:imageView];
                imageView.origin = CGPointMake(x, y);
                y = imageView.bottom + 10;
                
                CGImageRelease(img);
            }
        }
        CFRelease(imageSource);
    }
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *addImageItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    UIBarButtonItem *cleanFileItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean" style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
    self.navigationItem.rightBarButtonItems = @[addImageItem, cleanFileItem];
    
    // create directory
    NSString *directory = [[ImageIO sharedImageIO] fileDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
}

- (void)addImage {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
//        [self writeImageToPhotosAlbum:info];
        [self saveImageToDisk:info];
    } viewController:self];
}

- (void)clean {
    [self showLoadingMessage:@"remove image files in imageIO directory"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageDirectory = [[ImageIO sharedImageIO] fileDirectory];
        NSDirectoryEnumerator<NSString *> *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:imageDirectory];
        NSString *file = nil;
        while ((file = [enumerator nextObject]) != nil) {
            NSError *error = nil;
            BOOL res = [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
            if (!res) {
                NSLog(@"remove file %@ failed %@", file, error);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingMessage];
        });
    });
}

#pragma mark -

- (void)saveImageToDisk:(NSDictionary *)info {
    [self showLoadingMessage:@"save image to file"];
    
    // save image to file url
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSDictionary *dictMetadata = info[UIImagePickerControllerMediaMetadata];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *name = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
        NSString *path = [[[ImageIO sharedImageIO] fileDirectory] stringByAppendingPathComponent:name];
        
        // add gps info
//        if (!newMetadata[(__bridge id)kCGImagePropertyGPSDictionary]) {
            // TODO:location
//            CLLocationManager *locationManager = [CLLocationManager new];
//            // get nil here
//            CLLocation *location = [locationManager location];
//            newMetadata[(NSString *)kCGImagePropertyGPSDictionary] = [self gpsDictionaryForLocation:location];
//        }
        
        
        NSURL *url = [NSURL fileURLWithPath:path];
        BOOL res = [image writeJPEGDataWithMetadata:dictMetadata compressQuality:0.7 toURL:url];
        if (res) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addImageToViewWithURL:url];
                [self hideLoadingMessage];
            });
        } else {
            NSLog(@"%@, error", NSStringFromSelector(_cmd));
        }
    });
}

- (NSDictionary *)gpsDictionaryForLocation:(CLLocation *)location {
    NSTimeZone      *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HH:mm:ss.SS"];
    
    NSDictionary *gpsDict = @{(NSString *)kCGImagePropertyGPSLatitude: @(fabs(location.coordinate.latitude)),
                              (NSString *)kCGImagePropertyGPSLatitudeRef: ((location.coordinate.latitude >= 0) ? @"N" : @"S"),
                              (NSString *)kCGImagePropertyGPSLongitude: @(fabs(location.coordinate.longitude)),
                              (NSString *)kCGImagePropertyGPSLongitudeRef: ((location.coordinate.longitude >= 0) ? @"E" : @"W"),
                              (NSString *)kCGImagePropertyGPSTimeStamp: [formatter stringFromDate:[location timestamp]],
                              (NSString *)kCGImagePropertyGPSAltitude: @(fabs(location.altitude)),
                              };
    return gpsDict;
}

#pragma mark - save image to photosAlbum

- (void)writeImageToPhotosAlbum:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    if (!metadata[(__bridge id)kCGImagePropertyOrientation]) {
        NSMutableDictionary *mutableMetadata = [metadata mutableCopy];
        if (!mutableMetadata) {
            mutableMetadata = [NSMutableDictionary dictionary];
        }
        mutableMetadata[(__bridge id)kCGImagePropertyOrientation] = @([UIImage cc_iOSOrientationToExifOrientation:image.imageOrientation]);
        metadata = [mutableMetadata copy];
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [self showLoadingMessage:@"saving image to photosAlbum"];
    [library writeImageToSavedPhotosAlbum:image.CGImage
                                 metadata:metadata
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              NSLog(@"assetURL %@, error:%@", assetURL, error);
                              [self hideLoadingMessage];
                          }];
}

@end
