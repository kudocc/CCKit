//
//  ImageBlendViewController.m
//  demo
//
//  Created by KudoCC on 16/5/25.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageBlendViewController.h"
#import "ImagePickerViewControllerHelper.h"
#import "UIImage+CCKit.h"

@interface ImageBlendViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageBlendViewController

- (void)initView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenWidth)];
    [self.view addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self showRightBarButtonItemWithName:@"add image"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [self processImage:image];
    } viewController:self];
}

#define A(x) ((x >> 24) & 0xff)
#define B(x) ((x >> 16) & 0xff)
#define G(x) ((x >> 8) & 0xff)
#define R(x) ((x) & 0xff)
#define RGBA(r, g, b, a) ((r) + (g<<8) + (b<<16) + (a<<24))

- (void)processImage:(UIImage *)image {
    image = [image fixOrientationV2];
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPercomponent = 8;
    size_t bytesPerRow = 4 * width;
    char *bitmapData = calloc(1, bytesPerRow * height);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, bitsPercomponent, bytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    
    UIImage *imageTop = [UIImage imageNamed:@"avatar_ori"];
    imageTop = [imageTop fixOrientationV2];
    CGImageRef imageTopRef = imageTop.CGImage;
    size_t widthTop = CGImageGetWidth(imageTopRef);
    size_t heightTop = CGImageGetHeight(imageTopRef);
    size_t bytesPerRowTop = 4 * widthTop;
    char *bitmapDataTop = calloc(1, bytesPerRowTop * heightTop);
    CGContextRef contextTop = CGBitmapContextCreate(bitmapDataTop, widthTop, heightTop, bitsPercomponent, bytesPerRowTop, colorSpaceRef, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextDrawImage(contextTop, CGRectMake(0, 0, widthTop, heightTop), imageTopRef);
    
    uint32_t *int32BitmapData = (uint32_t *)bitmapData;
    uint32_t *int32BitmapDataTop = (uint32_t *)bitmapDataTop;
    for (int i = 0; i < heightTop; ++i) {
        for (int j = 0; j < widthTop; ++j) {
            int pos = j + i * (int)width;
            int posTop = j + i * (int)widthTop;
            uint32_t *data = int32BitmapData + pos;
            uint32_t *dataTop = int32BitmapDataTop + posTop;
            CGFloat alphaTop = (A(*dataTop)/255.0) * 0.5;
            uint32_t r = R(*data) * alphaTop + R(*dataTop) * (1-alphaTop);
            uint32_t g = R(*data) * alphaTop + R(*dataTop) * (1-alphaTop);
            uint32_t b = R(*data) * alphaTop + R(*dataTop) * (1-alphaTop);
            uint32_t a = A(*data);
            *data = RGBA(r, g, b, a);
        }
    }
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *imageNew = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    
    CGContextRelease(contextTop);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    
    free(bitmapDataTop);
    free(bitmapData);
    
    _imageView.image = imageNew;
}

@end
