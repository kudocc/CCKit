//
//  ImageSourceViewController.m
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageSourceViewController.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+CCKit.h"
#import "ImagePickerViewControllerHelper.h"

@implementation ImageSourceViewController {
    UIScrollView *scrollView;
}

- (void)addImageToViewWithCGImageSourceRef:(CGImageSourceRef)imageSource {
    CGFloat x = 0;
    CGFloat y = scrollView.contentSize.height;
    
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
    }
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, y);
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Image" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image_source" ofType:@"gif"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self addImageToViewWithURL:url];
}

- (void)addImage {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSDictionary *dictMetadata = info[UIImagePickerControllerMediaMetadata];
        NSLog(@"meta:%@", dictMetadata);
        
#if 0
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
#else 
        NSData *data = UIImagePNGRepresentation(image);
#endif
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        [self addImageToViewWithCGImageSourceRef:imageSource];
        CFRelease(imageSource);
        
    } viewController:self];
}

@end
