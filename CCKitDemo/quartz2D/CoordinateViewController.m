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
    
    /*
     假设整个区域的大小是200*200px，scale是2，srcPoint所在位置为(10, 10)point，被转换成Quartz的坐标系的位置应该是(20, 180)px
     srcPoint位于UIKit的坐标系中，UIKit要使用仿射变换使其变成Quartz的坐标系，我们模拟了这个过程
     在看代码之前，我们要考虑Quartz的坐标系是什么样的，我觉得Quartz应该跟`CGBitmapContextCreate`创建的context中使用的坐标系是一样的
     而这个context，我用`CGContextGetCTM(context)`拿到的坐标系仿射变换的值为[1, 0, 0, 1, 0, 0]
     因为UIKit中使用的是point，并且是以左上角为原点，所以UIKit要应用仿射变换将scrPoint的点变成同样位置的Quartz的点
     Height为区域的大小，单位是point
     如果scale为1，将srcPoint转换成Quartz的位置应该是 (srcPoint.x, Height - srcPoint.y)
     如果scale大于1，那么应该是(srcPoint.x * scale, (Height - srcPoint.y) * scale)
     所以可以做如下仿射变换，这应该就是UIKit创建CGContext时对CGContext做的仿射变换
     这里要注意的是这个函数以及相关的对transform做变换的函数，以CGAffineTransformTranslate(transform, x, y)为例
     他是将CGAffineTransformMakeTranslation(x, y)的结果与transform做矩阵相乘
     而不是transform与CGAffineTransformMakeTranslation(x, y)的结果相乘，矩阵相乘交换律不成立，所以千万小心
     */
    
    CGPoint srcPoint = CGPointMake(10, 10);
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale > 1) {
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        NSLog(@"%@", NSStringFromCGAffineTransform(transform));
        
        transform = CGAffineTransformTranslate(transform, 0, 100);
        NSLog(@"%@", NSStringFromCGAffineTransform(transform));
        
        transform = CGAffineTransformScale(transform, 1, -1);
        NSLog(@"%@", NSStringFromCGAffineTransform(transform));
        
        CGPoint dstPoint = CGPointApplyAffineTransform(srcPoint, transform);
        NSLog(@"src point:%@", NSStringFromCGPoint(srcPoint));
        NSLog(@"det point:%@", NSStringFromCGPoint(dstPoint));
    } else {
        CGAffineTransform transform = CGAffineTransformMakeScale(1/scale, 1/scale);
        NSLog(@"%@", NSStringFromCGAffineTransform(transform));
        transform = CGAffineTransformScale(transform, 1, -1);
        NSLog(@"%@", NSStringFromCGAffineTransform(transform));
        transform = CGAffineTransformTranslate(transform, 0, -200);
        NSLog(@"%@", NSStringFromCGAffineTransform(transform));
    }
}

@end

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
        CGPathAddArc(path, NULL, 100, 100, 100, 0, M_PI/2, YES);
        CGPathCloseSubpath(path);
        bezierPath = [UIBezierPath bezierPathWithCGPath:path];
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(path);
}

- (void)drawRect:(CGRect)rect {
    // 使用UIBezierPath和使用其path直接用CGContextDrawPath效果是一样的
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    
    [bezierPath stroke];
    
    // 使用CGContextDrawImage正确绘制图片
    CGFloat y = 200.0;
    NSLog(@"%@", NSStringFromCGAffineTransform(CGContextGetCTM(context)));
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, y+image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    CGContextRestoreGState(context);
}

@end
