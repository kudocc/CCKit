//
//  BuiltinFilterChainViewController.m
//  demo
//
//  Created by KudoCC on 16/5/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BuiltinFilterChainViewController.h"
#import "ImagePickerViewControllerHelper.h"
#import <CoreImage/CoreImage.h>

@implementation BuiltinFilterChainViewController {
    UIImageView *_imageView;
    UISlider *_slider;
    
    UIImageOrientation _orientation;
    CIImage *_ciImage;
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
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)addImage {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        _orientation = image.imageOrientation;
        _ciImage = [CIImage imageWithCGImage:image.CGImage];
        [self valueChanged:_slider];
    } viewController:self];
}

- (void)valueChanged:(UISlider *)slider {
    CGFloat value = slider.value;
    
    if (_ciImage) {
        CIImage *ciOutputImage = [self oldPhoto:_ciImage withAmount:value];
        
        CGImageRef cgImage = [_ciContext createCGImage:ciOutputImage fromRect:[ciOutputImage extent]];
        UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:_orientation];
        CGImageRelease(cgImage);
        _imageView.image = newImage;
    }
}

- (CIImage *)oldPhoto:(CIImage *)img withAmount:(float)intensity {
    CIFilter *random = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:random.outputImage forKey:kCIInputImageKey];
    [lighten setValue:@(1 - intensity) forKey:@"inputBrightness"];
    [lighten setValue:@0.0 forKey:@"inputSaturation"];
    CIImage *croppedImage = [lighten.outputImage imageByCroppingToRect:[img extent]];
    
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
    [sepia setValue:img forKey:kCIInputImageKey];
    [sepia setValue:@(intensity) forKey:@"inputIntensity"];
    
    CIFilter *composite = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [composite setValue:sepia.outputImage forKey:kCIInputImageKey];
    [composite setValue:croppedImage forKey:kCIInputBackgroundImageKey];
    
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignette"];
    [vignette setValue:composite.outputImage forKey:kCIInputImageKey];
    [vignette setValue:@(intensity * 2) forKey:@"inputIntensity"];
    [vignette setValue:@(intensity * 30) forKey:@"inputRadius"];
    
    return vignette.outputImage;
}

@end
