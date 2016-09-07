//
//  CIFaceAnimateFilter.m
//  CCKitDemo
//
//  Created by KudoCC on 16/9/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CIFaceAnimateFilter.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+CCKit.h"

@implementation CIFaceAnimateFilter {
    CIContext *_context;
    NSArray *_arrayFireImage;
    NSArray *_arrayFireImageRelativePos;
    NSInteger _indexFire;
    dispatch_queue_t _queue;
    CGPoint _mouthPosition;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        NSMutableArray *mutablePos = [NSMutableArray array];
        for (NSInteger i = 0; i < 20; ++i) {
            UIColor *color = [UIColor colorWithRed:(i+1)/10.0 green:0 blue:0 alpha:1];
            CGSize size = CGSizeMake(30.0 + 2*i, 30.0 + 2*i);
            UIImage *image = [UIImage cc_imageWithColor:color size:size borderWidth:0 borderColor:nil cornerRadius:size.width/2];
            CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage options:nil];
            [mutableArray addObject:ciImage];
            [mutablePos addObject:[NSValue valueWithCGPoint:CGPointMake(i+2, i+2)]];
        }
        _arrayFireImage = [mutableArray copy];
        _arrayFireImageRelativePos = [mutablePos copy];
        
        _indexFire = 0;
        
        _queue = dispatch_queue_create("face.detector.queue", 0);
        _mouthPosition = CGPointZero;
    }
    return self;
}

- (CIImage *)outputImage {
    CIImage *copyImage = [self.inputImage copy];
    dispatch_async(_queue, ^{
        
        if (!_context) {
            _context = [CIContext contextWithOptions:NULL];
//            EAGLContext *eContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//            _context = [CIContext contextWithEAGLContext:eContext];
        }
        
        NSDictionary *detectorOptions = @{CIDetectorAccuracy:CIDetectorAccuracyLow};
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:_context
                                                  options:detectorOptions];
        NSDictionary *opts = nil;
        if ([[copyImage properties] valueForKey:(__bridge id)kCGImagePropertyOrientation]) {
            opts = @{CIDetectorImageOrientation:[[copyImage properties] valueForKey:(__bridge id)kCGImagePropertyOrientation]};
        }
        NSArray *faceArray = [detector featuresInImage:copyImage options:opts];
        CIFaceFeature *first = [faceArray firstObject];
        if (first && [first hasMouthPosition]) {
            _mouthPosition = first.mouthPosition;
//            CGRect frame = first.bounds;
//            NSLog(@"face:%@, mouth:%@", NSStringFromCGRect(frame), NSStringFromCGPoint(_mouthPosition));
        } else {
            _mouthPosition = CGPointZero;
        }
    });
    
    if (!CGPointEqualToPoint(_mouthPosition, CGPointZero)) {
        _indexFire = ++_indexFire % _arrayFireImage.count;
        CIImage *imageFire = _arrayFireImage[_indexFire];
        CGPoint relativePos = [_arrayFireImageRelativePos[_indexFire] CGPointValue];
        
        CIFilter *filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
        CIImage *img = [imageFire imageByApplyingTransform:CGAffineTransformMakeTranslation(_mouthPosition.x - imageFire.extent.size.width/2 + relativePos.x, _mouthPosition.y - imageFire.extent.size.height/2 - relativePos.y)];
        [filter setValue:img forKey:kCIInputImageKey];
        [filter setValue:self.inputImage forKey:kCIInputBackgroundImageKey];
        return filter.outputImage;
    } else {
        _indexFire = 0;
        return self.inputImage;
    }
}

@end
