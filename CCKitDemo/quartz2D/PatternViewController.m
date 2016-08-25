//
//  PatternViewController.m
//  demo
//
//  Created by KudoCC on 16/5/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PatternViewController.h"

typedef void (*CGPatternDrawPatternCallback) (void *info, CGContextRef context);

void coloredPatternCallback(void *info, CGContextRef myContext) {
    CGFloat subunit = 5; // the pattern cell itself is 16 by 18
    
    CGRect  myRect1 = {{0,0}, {subunit, subunit}},
    myRect2 = {{subunit, subunit}, {subunit, subunit}},
    myRect3 = {{0,subunit}, {subunit, subunit}},
    myRect4 = {{subunit,0}, {subunit, subunit}};
    
    CGContextSetRGBFillColor (myContext, 0, 0, 1, 0.5);
    CGContextFillRect (myContext, myRect1);
    CGContextSetRGBFillColor (myContext, 1, 0, 0, 0.5);
    CGContextFillRect (myContext, myRect2);
    CGContextSetRGBFillColor (myContext, 0, 1, 0, 0.5);
    CGContextFillRect (myContext, myRect3);
    CGContextSetRGBFillColor (myContext, .5, 0, .5, 0.5);
    CGContextFillRect (myContext, myRect4);
}

void stencilPatternCallback(void *info, CGContextRef myContext) {
    printf("stencilPatternCallback\n");
    NSValue *value = (__bridge NSValue *)info;
    CGSize size = [value CGSizeValue];
    int k;
    double r, theta;
    
    r = 0.8 * size.width / 2;
    theta = 2 * M_PI * (2.0 / 5.0); // 144 degrees
    
    CGContextTranslateCTM (myContext, size.width/2, size.height/2);
    
    CGContextMoveToPoint(myContext, 0, r);
    for (k = 1; k < 5; k++) {
        CGContextAddLineToPoint (myContext,
                                 r * sin(k * theta),
                                 r * cos(k * theta));
    }
    CGContextClosePath(myContext);
    CGContextFillPath(myContext);
}

void stencilReleaseInfo(void *info) {
    NSValue *value = (__bridge_transfer NSValue *)info;
    value = nil;
}

@implementation PatternViewController

- (UIImage *)imageColoredPatternWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // create color space for pattern fill
    CGColorSpaceRef patternSpace;
    patternSpace = CGColorSpaceCreatePattern (NULL);
    CGContextSetFillColorSpace (context, patternSpace);
    CGColorSpaceRelease (patternSpace);
    
    const CGPatternCallbacks callback = {0, &coloredPatternCallback, NULL};
    CGPatternRef pattern = CGPatternCreate (NULL,
                                  CGRectMake(0, 0, 16, 16),
                                  CGAffineTransformIdentity,
                                  16, 18,
                                  kCGPatternTilingConstantSpacing,
                                  true,
                                  &callback);
    
    const CGFloat alpha = 1;
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
    
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage *)imageStencilPatternWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // create color space for pattern fill
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB ();
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(baseSpace);
    
    CGContextSetFillColorSpace (context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    CGColorSpaceRelease(baseSpace);
    
    const CGPatternCallbacks callback = {0, stencilPatternCallback, stencilReleaseInfo};
    CGSize sizePattern = CGSizeMake(10, 10);
    NSValue *valPatternSize = [NSValue valueWithCGSize:sizePattern];
    CGPatternRef pattern = CGPatternCreate ((__bridge_retained void *)(valPatternSize),
                                            CGRectMake(0, 0, sizePattern.width, sizePattern.height),
                                            CGAffineTransformIdentity,
                                            16, 18,
                                            kCGPatternTilingConstantSpacing,
                                            false,
                                            &callback);
    
    const CGFloat colors[4] = {1, 0, 0, 1};
    CGContextSetFillPattern(context, pattern, colors);
    CGPatternRelease(pattern);
    
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGSize size = CGSizeMake(ScreenWidth, ScreenWidth);
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:_scrollView];
    
    CGFloat y = 0;
    UIImage *image = [self imageColoredPatternWithSize:size];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor redColor].CGColor;
    y = imageView.bottom + 10;
    
    image = [self imageStencilPatternWithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    y = imageView.bottom + 10;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor redColor].CGColor;
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

@end
