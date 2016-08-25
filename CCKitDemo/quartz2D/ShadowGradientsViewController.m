//
//  ShadowGradientsViewController.m
//  demo
//
//  Created by KudoCC on 16/5/12.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ShadowGradientsViewController.h"
#import <CCLinearGradientView.h>

@implementation ShadowGradientsViewController


- (UIImage *)imageRadialGradientImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0, 0, 0, 0, 1.0};
    
    myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    
    
    CGPoint myStartPoint, myEndPoint;
    CGFloat myStartRadius, myEndRadius;
    myStartPoint.x = 0.15;
    myStartPoint.y = 0.15;
    myEndPoint.x = 0.5;
    myEndPoint.y = 0.5;
    myStartRadius = 0.1;
    myEndRadius = 0.25;
    CGContextDrawRadialGradient (context, myGradient, myStartPoint,
                                 myStartRadius, myEndPoint, myEndRadius, 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
    
    return image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    CGFloat y = 0;
    
    
    // create a shadow image
    CGSize size = CGSizeMake(ScreenWidth, ScreenWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    UIColor *fillColor = [UIColor whiteColor];
    CGRect rect = CGRectMake(10, 10, 100, 44);
    
    // re-draw the background
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // set top and left shadow
    CGRect rectTop = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 5);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, -5), 5, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rectTop);
    CGContextRestoreGState(context);
    
    CGRect rectLeft = CGRectMake(rect.origin.x, rect.origin.y, 5, rect.size.height);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(-5, 0), 5, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rectLeft);
    CGContextRestoreGState(context);
    
    // re-draw the background
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSaveGState(context);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4.0, 4.0)];
    [maskPath addClip];
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    
    UIImage *imageShadow = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageViewShadow = [[UIImageView alloc] initWithImage:imageShadow];
    [scrollView addSubview:imageViewShadow];
    imageViewShadow.frame = CGRectMake(0, 0, imageViewShadow.width, imageViewShadow.height);
    
    y = imageViewShadow.bottom + 10;
    
    // create a axial gradient view
    CCLinearGradientView *gradientView = [[CCLinearGradientView alloc] initWithFrame:CGRectMake(0, y, scrollView.width, scrollView.height) colors:@[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]] axis:CCLinerGradientViewAxisX];
    [scrollView addSubview:gradientView];
    y = gradientView.bottom + 10;
    
    
    // create a radial gradient view
    UIImage *imageRadial = [self imageRadialGradientImageWithSize:size];
    UIImageView *imageViewRadial = [[UIImageView alloc] initWithImage:imageRadial];
    [scrollView addSubview:imageViewRadial];
    imageViewRadial.frame = CGRectMake(0, y, imageViewRadial.width, imageViewRadial.height);
    y = imageViewRadial.bottom + 10;
    
    scrollView.contentSize = CGSizeMake(ScreenWidth, y);
}

@end
//