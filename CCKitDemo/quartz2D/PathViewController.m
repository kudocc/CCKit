//
//  PathViewController.m
//  demo
//
//  Created by KudoCC on 16/5/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PathViewController.h"
#import <math.h>

@implementation PathViewController

/// 一个稍微复杂的绘制
- (UIImage *)imagePieChartWithPercentArray:(NSArray *)percents colors:(NSArray *)colors imageSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, 0, size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGFloat radius = MIN(size.width, size.height) / 4;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGFloat start = 0;
    __block CGFloat currentAngle = start;
    [percents enumerateObjectsUsingBlock:^(NSNumber *percent, NSUInteger idx, BOOL * _Nonnull stop) {
        CGContextMoveToPoint(context, center.x, center.y);
        CGFloat angle = percent.floatValue / 100 * 2 * M_PI;
        UIColor *color = colors[idx];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGFloat endAngle = currentAngle+angle;
        CGContextAddArc(context, center.x, center.y, radius, currentAngle, endAngle, 0);
        CGContextFillPath(context);
        
        CGFloat midAngle = (currentAngle + endAngle) / 2;
        CGFloat midY = radius*sin(midAngle) + center.y;
        CGFloat midX = radius*cos(midAngle) + center.x;
        CGFloat odd = 20.0;
        CGContextMoveToPoint(context, midX, midY);
        CGPoint moveTo = CGPointMake((radius+odd)*cos(midAngle) + center.x, (radius+odd)*sin(midAngle) + center.y);
        CGContextAddLineToPoint(context, moveTo.x, moveTo.y);
        BOOL leftSide = moveTo.x < center.x ;
        moveTo.x += odd * (leftSide ? -1 : 1);
        CGContextAddLineToPoint(context, moveTo.x, moveTo.y);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextStrokePath(context);
        
        CGPoint drawPoint = moveTo;
        drawPoint.x += leftSide ? -50 : 0;
        drawPoint.y -= 10.0;
        NSString *string = [NSString stringWithFormat:@"%.2f%%", percent.floatValue];
        [string drawAtPoint:drawPoint withAttributes:@{}];
        
        currentAngle = endAngle;
    }];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


/**
 在context上绘制一个subpath，不绘制这个subpath，然后调用CGContextMoveToPoint，那么之前的path会被绘制上去吗
 
 结果是可以绘制上去，之前的path是context的subpath，调用CGContextMoveToPoint开始了一个新的subpath
 */
- (UIImage *)imageTest1WithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextMoveToPoint(context, size.width/2, size.height/2);
    CGContextAddArc(context, size.width/2, size.height/2, floor(size.width/2), 0, M_PI/2, 1);
    
    CGContextMoveToPoint(context, size.width, size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageTest1BitmapContextWithSize:(CGSize)size {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    size = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(scale, scale));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaNoneSkipLast);
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextMoveToPoint(context, size.width/2, size.height/2);
    CGContextAddArc(context, size.width/2, size.height/2, floor(size.width/2), 0, M_PI/2, 1);
    
    CGContextMoveToPoint(context, size.width, size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
    
    CGImageRef imageRes = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRes scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRes);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
//    CGPathRelease(mPath);
    
    return image;
}

/**
 在context上绘制一个subpath，不绘制这个subpath，然后调用类似`CGContextStrokeRect`的方法，那么这个path会被绘制上去么?
 
 结果是没有绘制之前的subpath，`CGContextStrokeRect`的Discussion中解释：As a side effect when you call this function, Quartz clears the current path，所以除非在调用这个方法之前调用`CGContextStrokeRect`，否则不会绘制当前的path了。
 */
- (UIImage *)imageTest2WithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, size.width/2, size.height/2);
    CGContextAddArc(context, size.width/2, size.height/2, floor(size.width/2), 0, M_PI/2, 1);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    rect = CGRectInset(rect, 10, 10);
    CGContextStrokeRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// CGContext的绘制都是先依照Quartz的坐标系绘制，然后根据当前context的CTM，将坐标变换成目标值

/**
 调用`CGContextFillPath`方法会自动视当前的path为调用CGContextClosePath的结果
 */
- (UIImage *)imageTestAutoClosePathWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // 这里如果不调用这个方法，自动close path的时候会视start point为arc的开始点
    CGContextMoveToPoint(context, size.width/2, size.height/2);
    
    CGContextAddArc(context, size.width/2, size.height/2, floor(size.width/2), 0, M_PI/2, 1);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageTestArcWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height/2);
    CGFloat radius = rect.size.height/2;
    CGContextMoveToPoint(context, radius, 0);
    CGContextAddArcToPoint(context, 0, 0, 0, radius, radius/2);
    
    CGContextMoveToPoint(context, rect.size.width-radius, 0);
    CGContextAddArcToPoint(context, rect.size.width, 0, rect.size.width, radius, radius);
    CGContextStrokePath(context);
    
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
    
    /// draw a pie style image
    NSArray *percents = @[@10, @20, @30, @40];
    NSArray *colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor yellowColor]];
    UIImage *image = [self imagePieChartWithPercentArray:percents colors:colors imageSize:size];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    y = imageView.bottom + 10;
    
    
    image = [self imageTest1WithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    y = imageView.bottom + 10;
    
    
    image = [self imageTest1BitmapContextWithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    y = imageView.bottom + 10;
    
    
    image = [self imageTest2WithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    y = imageView.bottom + 10;
    
    
    image = [self imageTestAutoClosePathWithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor redColor].CGColor;
    y = imageView.bottom + 10;
    
    
    image = [self imageTestArcWithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor redColor].CGColor;
    y = imageView.bottom + 10;
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

@end
