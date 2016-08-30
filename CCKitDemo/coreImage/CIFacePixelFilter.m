//
//  CIFacePixelFilter.m
//  CCKitDemo
//
//  Created by KudoCC on 16/8/29.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CIFacePixelFilter.h"
#import <ImageIO/ImageIO.h>

@implementation CIFacePixelFilter

- (CIImage *)outputImage {
    NSDictionary *detectorOptions = @{CIDetectorAccuracy:CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:detectorOptions];
    NSDictionary *opts = nil;
    if ([[self.inputImage properties] valueForKey:(__bridge id)kCGImagePropertyOrientation]) {
        opts = @{CIDetectorImageOrientation:[[self.inputImage properties] valueForKey:(__bridge id)kCGImagePropertyOrientation]};
    }
    NSArray *faceArray = [detector featuresInImage:self.inputImage options:opts];
    
    // Create a green circle to cover the rects that are returned.
    CIImage *maskImage = nil;
    for (CIFeature *f in faceArray) {
        CGFloat centerX = f.bounds.origin.x + f.bounds.size.width / 2.0;
        CGFloat centerY = f.bounds.origin.y + f.bounds.size.height / 2.0;
        CGFloat radius = MIN(f.bounds.size.width, f.bounds.size.height) / 1.5;
        CIFilter *radialGradient = [CIFilter filterWithName:@"CIRadialGradient"];
        [radialGradient setValue:@(radius) forKey:@"inputRadius0"];
        [radialGradient setValue:@(radius + 1.0f) forKey:@"inputRadius1"];
        [radialGradient setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forKey:@"inputColor0"];
        [radialGradient setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] forKey:@"inputColor1"];
        [radialGradient setValue:[CIVector vectorWithX:centerX Y:centerY] forKey:kCIInputCenterKey];
        
        CIImage *circleImage = [radialGradient valueForKey:kCIOutputImageKey];
        if (nil == maskImage)
            maskImage = circleImage;
        else {
            CIFilter *filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
            [filter setValue:circleImage forKey:kCIInputImageKey];
            [filter setValue:maskImage forKey:kCIInputBackgroundImageKey];
            maskImage = filter.outputImage;
        }
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
