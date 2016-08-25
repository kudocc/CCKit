//
//  CoordinateViewController.m
//  demo
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoordinateViewController.h"

@implementation CoordinateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewCordinate *v = [[UIViewCordinate alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:v];
}

@end

void MyDrawWithShadows (CGContextRef myContext, CGFloat wd, CGFloat ht)
{
    CGSize          myShadowOffset = CGSizeMake (-15,  20);// 2
    CGFloat           myColorValues[] = {1, 0, 0, .6};// 3
    CGColorRef      myColor;// 4
    CGColorSpaceRef myColorSpace;// 5
    
    CGContextSaveGState(myContext);// 6
    
    CGContextSetShadow (myContext, myShadowOffset, 5); // 7
    // Your drawing code here// 8
    CGContextSetRGBFillColor (myContext, 0, 1, 0, 1);
    CGContextFillRect (myContext, CGRectMake (wd/3 + 75, ht/2 , wd/4, ht/4));
    
    myColorSpace = CGColorSpaceCreateDeviceRGB ();// 9
    myColor = CGColorCreate (myColorSpace, myColorValues);// 10
    CGContextSetShadowWithColor (myContext, myShadowOffset, 5, myColor);// 11
    // Your drawing code here// 12
    CGContextSetRGBFillColor (myContext, 0, 0, 1, 1);
    CGContextFillRect (myContext, CGRectMake (wd/3-75,ht/2-100,wd/4,ht/4));
    
    CGColorRelease (myColor);// 13
    CGColorSpaceRelease (myColorSpace); // 14
    
    CGContextRestoreGState(myContext);// 15
}

@implementation UIViewCordinate {
    UIImage *image;
    CGMutablePathRef path;
    UIBezierPath *bezierPath;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        image = [UIImage imageNamed:@"ori"];
        
        path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, 100, 100, 100, 0, M_PI/4, YES);
        CGPathCloseSubpath(path);
        bezierPath = [UIBezierPath bezierPathWithCGPath:path];
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(path);
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat y = 64;
    [image drawInRect:CGRectMake(0, y, image.size.width, image.size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    MyDrawWithShadows(context, 100, 100);
    {
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, 100, 100, 100, 0, M_PI/4, YES);
        CGPathCloseSubpath(path);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathStroke);
        [bezierPath stroke];
    }
    
    
    NSLog(@"%@", NSStringFromCGAffineTransform(CGContextGetCTM(context)));
    y += image.size.height;
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, y+image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    CGContextRestoreGState(context);
    
    // flip y
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    NSLog(@"%@", NSStringFromCGAffineTransform(CGContextGetCTM(context)));
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    {
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, 100, 100, 100, 0, M_PI/4, YES);
        CGPathCloseSubpath(path);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathStroke);
        [bezierPath stroke];
    }
    
    MyDrawWithShadows(context, 100, 100);
}

@end
