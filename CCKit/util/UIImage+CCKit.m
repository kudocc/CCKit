//
//  UIImage+CCKit.m
//  performance
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIImage+CCKit.h"
#import <ImageIO/ImageIO.h>
#import "UIView+CCKit.h"

@implementation UIImage (CCKit)

+ (UIImage *)cc_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)cc_imageWithColor:(UIColor *)color size:(CGSize)size borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)radius {
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(borderWidth/2, borderWidth/2, borderWidth/2, borderWidth/2));
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius];
    [path setLineWidth:borderWidth];
    [borderColor setStroke];
    [path fill];
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)cc_imageWithColor:(UIColor *)color size:(CGSize)size lineWidth:(CGFloat)lineWidth dashLineColor:(UIColor *)dashLineColor cornerRadius:(CGFloat)radius {
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(lineWidth/2, lineWidth/2, lineWidth/2, lineWidth/2));
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius];
    CGFloat dash[2] = {2, 2};
    [path setLineDash:dash count:2 phase:2];
    [path setLineWidth:lineWidth];
    [path setLineCapStyle:kCGLineCapRound];
    [dashLineColor setStroke];
    [path fill];
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)cc_resizeImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode size:(CGSize)size {
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGRect frameImage = [UIView cc_frameOfContentWithContentSize:image.size containerSize:size contentMode:contentMode];
    [image drawInRect:frameImage];
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}


- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius {
    return [self cc_imageWithSize:size cornerRadius:radius contentMode:UIViewContentModeScaleToFill];
}

- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode {
    return [self cc_imageWithSize:size cornerRadius:radius borderWidth:0 borderColor:nil contentMode:contentMode];
}

- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor contentMode:(UIViewContentMode)contentMode {
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // add clip area
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 0.0, size.width, size.height) cornerRadius:radius];
    [path addClip];
    
    // draw image
    CGRect frame = [UIView cc_frameOfContentWithContentSize:self.size containerSize:size contentMode:contentMode];
    [self drawInRect:frame];
    
    // draw border
    if (borderWidth > 0 && borderColor) {
        path.lineWidth = borderWidth*2;
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)cc_gradientImageWithSize:(CGSize)size colors:(NSArray *)colors axisX:(BOOL)axisX {
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    NSAssert([colors count] > 1, @"at least two colors");
    CGColorSpaceRef myColorspace;
    size_t num_locations = (size_t)colors.count;
    CGFloat *locations = (CGFloat *)malloc(sizeof(CGFloat) * num_locations);
    CGFloat *components = (CGFloat *)malloc(sizeof(CGFloat) * 4 * num_locations);
    for (NSUInteger i = 0; i < colors.count; ++i) {
        if (i == 0) {
            *(locations+i) = 0;
        } else {
            *(locations+i) = *(locations+i-1) + 1.0/(num_locations-1);
        }
        CGFloat *pos = components + 4 * i;
        UIColor *color = colors[i];
        BOOL res = [color getRed:pos green:pos+1 blue:pos+2 alpha:pos+3];
        NSAssert(res, @"fetch color from UIColor error");
        if (!res) {
            *pos = 0;
            *(pos+1) = 0;
            *(pos+2) = 0;
            *(pos+3) = 1;
        }
    }
    myColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    CGColorSpaceRelease(myColorspace);
    free(locations);
    free(components);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint startPoint = CGPointMake(0.0, 0.0);
    CGPoint endPoint = CGPointMake(0.0, size.height);
    if (axisX) {
        endPoint = CGPointMake(size.width, 0.0);
    } else {
        endPoint = CGPointMake(0.0, size.height);
    }
    CGContextDrawLinearGradient (context, gradient, startPoint, endPoint, 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGGradientRelease(gradient);
    return image;
}


+ (UIImage *)cc_imageWithQRCodeString:(NSString *)qrCode imageSize:(CGSize)size {
    NSData *stringData = [qrCode dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *ciImage = qrFilter.outputImage;
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:ciImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

// Reference: http://sylvana.net/jpegcrop/exif_orientation.html
+ (int)cc_iOSOrientationToExifOrientation:(UIImageOrientation)iOSOrientation {
    int exifOrientation = -1;
    switch (iOSOrientation) {
        case UIImageOrientationUp:
            exifOrientation = 1;
            break;
            
        case UIImageOrientationDown:
            exifOrientation = 3;
            break;
            
        case UIImageOrientationLeft:
            exifOrientation = 8;
            break;
            
        case UIImageOrientationRight:
            exifOrientation = 6;
            break;
            
        case UIImageOrientationUpMirrored:
            exifOrientation = 2;
            break;
            
        case UIImageOrientationDownMirrored:
            exifOrientation = 4;
            break;
            
        case UIImageOrientationLeftMirrored:
            exifOrientation = 5;
            break;
            
        case UIImageOrientationRightMirrored:
            exifOrientation = 7;
            break;
            
        default:
            exifOrientation = -1;
    }
    return exifOrientation;
}

+ (UIImageOrientation)cc_exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
            
        case 3:
            orientation = UIImageOrientationDown;
            break;
            
        case 8:
            orientation = UIImageOrientationLeft;
            break;
            
        case 6:
            orientation = UIImageOrientationRight;
            break;
            
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
            
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
            
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
            
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return orientation;
}

- (NSString *)cc_description {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    NSString *strAlphaInfo = @"";
    switch (alphaInfo) {
        case kCGImageAlphaNone:
            strAlphaInfo = @"None";
            break;
        case kCGImageAlphaPremultipliedLast:
            strAlphaInfo = @"PremultipliedLast";
            break;
        case kCGImageAlphaPremultipliedFirst:
            strAlphaInfo = @"PremultipliedFirst";
            break;
        case kCGImageAlphaLast:
            strAlphaInfo = @"AlphaLast";
            break;
        case kCGImageAlphaFirst:
            strAlphaInfo = @"AlphaFirst";
            break;
        case kCGImageAlphaNoneSkipLast:
            strAlphaInfo = @"NoneSkipLast";
            break;
        case kCGImageAlphaNoneSkipFirst:
            strAlphaInfo = @"NoneSkipFirst";
            break;
        case kCGImageAlphaOnly:
            strAlphaInfo = @"AlphaOnly";
            break;
        default:
            break;
    }
    size_t bitsPerPixel = CGImageGetBitsPerPixel(self.CGImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(self.CGImage);
    NSString *des = [NSString stringWithFormat:@"alpha:%@, bitsPerPixel:%@, bitsPerComponent:%@, size:%@", strAlphaInfo, @(bitsPerPixel), @(bitsPerComponent), NSStringFromCGSize(self.size)];
    return des;
}

@end



@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)fixOrientationV2 {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end


@implementation UIImage (UIImagePickerController)

- (NSData *)pngDataWithMetadata:(NSDictionary *)metadata {
    NSData *data = UIImagePNGRepresentation(self);
    return [self imageDataWithOriData:data metadata:metadata];
}

- (NSData *)jpegDataWithMetadata:(NSDictionary *)metadata compressQuality:(CGFloat)compressionQuality {
    NSData *data = UIImageJPEGRepresentation(self, compressionQuality);
    return [self imageDataWithOriData:data metadata:metadata];
}

- (NSData *)imageDataWithOriData:(NSData *)oriData metadata:(NSDictionary *)metadata {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)oriData, NULL);
    if (!source) {
        return nil;
    }
    CFStringRef UTI = CGImageSourceGetType(source);
    NSMutableData *mutableData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, UTI, 1, NULL);
    if (!destination) {
        CFRelease(source);
        return nil;
    }
    int exifOrientation = [UIImage cc_iOSOrientationToExifOrientation:self.imageOrientation];
    if (!metadata[(__bridge id)kCGImagePropertyOrientation]) {
        NSMutableDictionary *mutableDict = [metadata mutableCopy];
        if (!mutableDict) {
            mutableDict = [NSMutableDictionary dictionary];
        }
        mutableDict[(__bridge id)kCGImagePropertyOrientation] = @(exifOrientation);
        metadata = [mutableDict copy];
    }
    
    // PNG虽然没有orientation，但是在应用kCGImagePropertyOrientation这个属性的时候，图片会旋转，使orientation变成up，达到与原图是一样的效果
    // JPEG即使不加metadata这个property，本身也自带oritentation属性，不会产生旋转的现象
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)metadata);
    bool success = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CFRelease(source);
    if (success) {
        return [mutableData copy];
    } else {
        return nil;
    }
}



- (BOOL)writePNGDataWithMetadata:(NSDictionary *)metadata toURL:(NSURL *)url {
    NSData *data = UIImagePNGRepresentation(self);
    return [self writeImageDataWithOriData:data metadata:metadata toURL:url];
}

- (BOOL)writeJPEGDataWithMetadata:(NSDictionary *)metadata compressQuality:(CGFloat)compressionQuality toURL:(NSURL *)url {
    NSData *data = UIImageJPEGRepresentation(self, compressionQuality);
    return [self writeImageDataWithOriData:data metadata:metadata toURL:url];
}

- (BOOL)writeImageDataWithOriData:(NSData *)oriData metadata:(NSDictionary *)metadata  toURL:(NSURL *)url {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)oriData, NULL);
    if (!source) {
        return NO;
    }
    CFStringRef UTI = CGImageSourceGetType(source);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)url, UTI, 1, NULL);
    if (!destination) {
        CFRelease(source);
        return NO;
    }
    
    int exifOrientation = [UIImage cc_iOSOrientationToExifOrientation:self.imageOrientation];
    if (!metadata[(__bridge id)kCGImagePropertyOrientation]) {
        NSMutableDictionary *mutableDict = [metadata mutableCopy];
        if (!mutableDict) {
            mutableDict = [NSMutableDictionary dictionary];
        }
        mutableDict[(__bridge id)kCGImagePropertyOrientation] = @(exifOrientation);
        metadata = [mutableDict copy];
    }
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)metadata);
    BOOL success = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CFRelease(source);
    return success;
}

@end


@implementation UIImage (ImageMask)

- (NSString *)kcc_description:(CGImageRef)imageRef {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    NSString *strAlphaInfo = @"";
    switch (alphaInfo) {
        case kCGImageAlphaNone:
            strAlphaInfo = @"None";
            break;
        case kCGImageAlphaPremultipliedLast:
            strAlphaInfo = @"PremultipliedLast";
            break;
        case kCGImageAlphaPremultipliedFirst:
            strAlphaInfo = @"PremultipliedFirst";
            break;
        case kCGImageAlphaLast:
            strAlphaInfo = @"AlphaLast";
            break;
        case kCGImageAlphaFirst:
            strAlphaInfo = @"AlphaFirst";
            break;
        case kCGImageAlphaNoneSkipLast:
            strAlphaInfo = @"NoneSkipLast";
            break;
        case kCGImageAlphaNoneSkipFirst:
            strAlphaInfo = @"NoneSkipFirst";
            break;
        case kCGImageAlphaOnly:
            strAlphaInfo = @"AlphaOnly";
            break;
        default:
            break;
    }
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    NSString *des = [NSString stringWithFormat:@"alpha:%@, bitsPerPixel:%@, bitsPerComponent:%@", strAlphaInfo, @(bitsPerPixel), @(bitsPerComponent)];
    return des;
}

- (UIImage *)cc_imageMask {
    CGImageRef maskRef = self.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    UIImage *image = [UIImage imageWithCGImage:mask scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(mask);
    return image;
}

@end