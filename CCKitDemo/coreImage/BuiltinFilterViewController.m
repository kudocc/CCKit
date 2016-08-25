//
//  BuiltinFilterViewController.m
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BuiltinFilterViewController.h"
#import "ImagePickerViewControllerHelper.h"
#import <CoreImage/CoreImage.h>

@implementation BuiltinFilterViewController {
    UIImageView *_imageView;
    UISlider *_slider;
    
    UIImageOrientation _orientation;
    CIImage *_ciImage;
    CIFilter *_ciFilter;
    CIContext *_ciContext;
}

- (void)initView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenWidth)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _slider = [[UISlider alloc] init];
    [self.view addSubview:_slider];
    _slider.frame = CGRectMake(10, _imageView.bottom + 10, ScreenWidth-20, _slider.height);
    _slider.maximumValue = 1.0;
    _slider.minimumValue = 0.0;
    _slider.value = 1.0;
    [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _ciContext = [CIContext contextWithOptions:NULL];
    _ciFilter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:@"inputIntensity", @1.0, nil];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)addImage {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        _orientation = image.imageOrientation;
        _ciImage = [CIImage imageWithCGImage:image.CGImage];
        [_ciFilter setValue:_ciImage forKey:kCIInputImageKey];
        [self valueChanged:_slider];
    } viewController:self];
}

- (void)valueChanged:(UISlider *)slider {
    CGFloat value = slider.value;
    
    if (_ciImage) {
        [_ciFilter setValue:@(value) forKey:@"inputIntensity"];
        CIImage *ciOutputImage = [_ciFilter outputImage];
        CGImageRef cgImage = [_ciContext createCGImage:ciOutputImage fromRect:[ciOutputImage extent]];
        UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:_orientation];
        CGImageRelease(cgImage);
        _imageView.image = newImage;
    }
}

@end
