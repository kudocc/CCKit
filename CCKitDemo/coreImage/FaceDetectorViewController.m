//
//  FaceDetectorViewController.m
//  demo
//
//  Created by KudoCC on 16/5/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "FaceDetectorViewController.h"
#import "ImagePickerViewControllerHelper.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import "UIImage+CCKit.h"

@implementation FaceDetectorViewController {
    UIImageView *_imageView;
    
    CIDetector *_ciDetector;
    CIContext *_ciContext;
    UIImageOrientation _orientation;
    CIImage *_ciImage;
}

- (void)initView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenWidth)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _ciContext = [CIContext contextWithOptions:NULL];
    NSDictionary *options = @{CIDetectorAccuracy:CIDetectorAccuracyHigh};
    _ciDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:_ciContext options:options];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Get image from photo" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UIImage *image = [UIImage imageNamed:@"face_detect"];
    [self handleImage:image];
}

- (void)addImage {
    [[ImagePickerViewControllerHelper sharedHelper] presentImagePickerWithBlock:^(NSDictionary<NSString *,id> *info) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [self handleImage:image];
    } viewController:self];
}

- (void)handleImage:(UIImage *)image {
    image = [UIImage cc_resizeImage:image contentMode:_imageView.contentMode size:CGSizeMake(ScreenWidth, ScreenWidth)];
    _imageView.image = image;
    _imageView.frame = CGRectMake(ScreenWidth/2-image.size.width/2, 64, image.size.width, image.size.height);
    
    _orientation = image.imageOrientation;
    _ciImage = [CIImage imageWithCGImage:image.CGImage];
    [self detectImage:_ciImage];
}

- (CGRect)rectAfterScale:(CGRect)rect {
    CGFloat scale = [UIScreen mainScreen].scale;
    rect = CGRectMake(rect.origin.x/scale, rect.origin.y/scale, rect.size.width/scale, rect.size.height/scale);
    return rect;
}

- (CGPoint)pointAfterScale:(CGPoint)point {
    CGFloat scale = [UIScreen mainScreen].scale;
    point = CGPointMake(point.x/scale, point.y/scale);
    return point;
}

- (void)detectImage:(CIImage *)ciImage {
    NSArray *array = [_imageView.layer.sublayers copy];
    for (CALayer *layer in array) {
        [layer removeFromSuperlayer];
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, _imageView.height);
    transform = CGAffineTransformScale(transform, 1/scale, -1/scale);
    
    NSDictionary *opts = nil;
    if ([[ciImage properties] valueForKey:(__bridge id)kCGImagePropertyOrientation]) {
        opts = @{CIDetectorImageOrientation:[[ciImage properties] valueForKey:(__bridge id)kCGImagePropertyOrientation]};
    }
    NSArray *features = [_ciDetector featuresInImage:ciImage options:opts];
    
    for (CIFaceFeature *f in features) {
        NSLog(@"bounds:%@", NSStringFromCGRect(f.bounds));
        CGRect faceBounds = CGRectApplyAffineTransform(f.bounds, transform);
        CALayer *layer = [CALayer layer];
        layer.frame = faceBounds;
        layer.borderColor = [UIColor yellowColor].CGColor;
        layer.borderWidth = PixelToPoint(1);
        [_imageView.layer addSublayer:layer];
        
        if (f.hasLeftEyePosition) {
            NSLog(@"Left eye %g %g", f.leftEyePosition.x, f.leftEyePosition.y);
            CALayer *layerLeftEye = [CALayer layer];
            layerLeftEye.frame = CGRectMake(0, 0, 20, 20);
            layerLeftEye.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3].CGColor;
            layerLeftEye.position = CGPointApplyAffineTransform(f.leftEyePosition, transform);
            [_imageView.layer addSublayer:layerLeftEye];
        }
        if (f.hasRightEyePosition) {
            NSLog(@"Right eye %g %g", f.rightEyePosition.x, f.rightEyePosition.y);
            CALayer *layerRightEye = [CALayer layer];
            layerRightEye.frame = CGRectMake(0, 0, 20, 20);
            layerRightEye.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3].CGColor;
            layerRightEye.position = CGPointApplyAffineTransform(f.rightEyePosition, transform);
            [_imageView.layer addSublayer:layerRightEye];
        }
        if (f.hasMouthPosition) {
            NSLog(@"Mouth %g %g", f.mouthPosition.x, f.mouthPosition.y);
            CALayer *layerMouth = [CALayer layer];
            layerMouth.frame = CGRectMake(0, 0, 20, 20);
            layerMouth.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3].CGColor;
            layerMouth.position = CGPointApplyAffineTransform(f.mouthPosition, transform);
            [_imageView.layer addSublayer:layerMouth];
        }
    }
}

@end
