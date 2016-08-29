//
//  CIFacePixelFilter.m
//  CCKitDemo
//
//  Created by KudoCC on 16/8/29.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CIFacePixelFilter.h"

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
