//
//  PathViewController.m
//  demo
//
//  Created by KudoCC on 16/5/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PathViewController.h"


@implementation PathViewController

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
    rect = CGRectInset(rect, 2, 2);
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
    UIImage *image = [self imageTest1WithSize:size];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor redColor].CGColor;
    y = imageView.bottom + 10;
    
    image = [self imageTest2WithSize:size];
    imageView = [[UIImageView alloc] initWithImage:image];
    [_scrollView addSubview:imageView];
    imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
    y = imageView.bottom + 10;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor redColor].CGColor;
    
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
