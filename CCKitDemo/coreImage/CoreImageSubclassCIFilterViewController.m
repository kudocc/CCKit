//
//  CoreImageSubclassCIFilterViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 16/8/29.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreImageSubclassCIFilterViewController.h"
#import "ImagePickerViewControllerHelper.h"
#import "CIFacePixelFilter.h"

@implementation CoreImageSubclassCIFilterViewController {
    UIImageView *_imageView;
    
    UIImageOrientation _orientation;
    CIImage *_ciImage;
    CIFilter *_ciFilter;
    CIContext *_ciContext;
}

- (void)initView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenWidth)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _ciContext = [CIContext contextWithOptions:NULL];
    _ciFilter = [[CIFacePixelFilter alloc] init];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)addImage {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSDictionary *meta = info[UIImagePickerControllerMediaMetadata];
        
        _orientation = image.imageOrientation;
        NSDictionary *options = nil;
        if (info && meta) {
            options = @{kCIImageProperties:meta};
        }
        _ciImage = [CIImage imageWithCGImage:image.CGImage options:options];
        [_ciFilter setValue:_ciImage forKey:kCIInputImageKey];
        [self valueChanged:nil];
    } viewController:self];
}

- (void)valueChanged:(id)obj {
    if (_ciImage) {
        CIImage *ciOutputImage = [_ciFilter outputImage];
        CGImageRef cgImage = [_ciContext createCGImage:ciOutputImage fromRect:[ciOutputImage extent]];
        UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:_orientation];
        CGImageRelease(cgImage);
        _imageView.image = newImage;
    }
}

@end
