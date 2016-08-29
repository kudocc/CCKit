//
//  CoreImageSubclassCIFilterViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 16/8/29.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreImageSubclassCIFilterViewController.h"
#import "ImagePickerViewControllerHelper.h"
#import <CoreImage/CoreImage.h>

@interface CIFacePixelFilter : CIFilter

@property (nonatomic) CIImage *inputImage;

@end

@implementation CIFacePixelFilter

- (CIImage *)outputImage {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:nil];
    NSArray *faceArray = [detector featuresInImage:self.inputImage options:nil];
    
    // Create a green circle to cover the rects that are returned.
    CIImage *maskImage = nil;
    for (CIFeature *f in faceArray) {
        CGFloat centerX = f.bounds.origin.x + f.bounds.size.width / 2.0;
        CGFloat centerY = f.bounds.origin.y + f.bounds.size.height / 2.0;
        CGFloat radius = MIN(f.bounds.size.width, f.bounds.size.height) / 1.5;
        CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient" withInputParameters:@{
                                                                                                      @"inputRadius0": @(radius),
                                                                                                      @"inputRadius1": @(radius + 1.0f),
                                                                                                      @"inputColor0": [CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0],
                                                                                                      @"inputColor1": [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                                                                                                      kCIInputCenterKey: [CIVector vectorWithX:centerX Y:centerY],
                                                                                                      }];
        CIImage *circleImage = [radialGradient valueForKey:kCIOutputImageKey];
        if (nil == maskImage)
            maskImage = circleImage;
        else
            maskImage = [[CIFilter filterWithName:@"CISourceOverCompositing" withInputParameters:@{
                                                                                                   kCIInputImageKey: circleImage,
                                                                                                   kCIInputBackgroundImageKey: maskImage,
                                                                                                   }] valueForKey:kCIOutputImageKey];
    }
    
    if (!maskImage) {
        return self.inputImage;
    }
    
    CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
    [pixellateFilter setValue:self.inputImage forKey:kCIInputImageKey];
    CGFloat scale = MAX(self.inputImage.extent.size.width, self.inputImage.extent.size.height)/60;
    [pixellateFilter setValue:@(scale) forKey:kCIInputScaleKey];
    CIImage *output = pixellateFilter.outputImage;
    
    CIFilter *blendWithMask = [CIFilter filterWithName:@"CIBlendWithMask"];
    [blendWithMask setValue:output forKey:kCIInputImageKey];
    [blendWithMask setValue:maskImage forKey:kCIInputMaskImageKey];
    [blendWithMask setValue:self.inputImage forKey:kCIInputBackgroundImageKey];
    return blendWithMask.outputImage;
}

@end

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
        _orientation = image.imageOrientation;
        _ciImage = [CIImage imageWithCGImage:image.CGImage];
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
