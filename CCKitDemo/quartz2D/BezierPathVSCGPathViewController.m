//
//  BezierPathVSCGPathViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/8/22.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "BezierPathVSCGPathViewController.h"

@interface UIViewBezierPath : UIView

@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;

@end

@implementation UIViewBezierPath

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    if (size.width == 0 || size.height == 0) {
        return;
    }
    
    [[UIColor redColor] setFill];
    [[UIColor blackColor] setStroke];
    
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(self.borderWidth / 2, self.borderWidth / 2, self.borderWidth / 2, self.borderWidth / 2));
    
    CGFloat cornerRadius = 0;
    if (self.cornerRadius <= 0) {
        cornerRadius = size.height/2;
    } else {
        cornerRadius = self.cornerRadius - self.borderWidth/2;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius];
    path.lineWidth = self.borderWidth;
    [path fill];
    [path stroke];
}

@end

@interface UIViewCGPath : UIView
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;
@end

@implementation UIViewCGPath

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    if (size.width == 0 || size.height == 0) {
        return;
    }
    
    [[UIColor redColor] setFill];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(self.borderWidth / 2, self.borderWidth / 2, self.borderWidth / 2, self.borderWidth / 2));
    CGFloat cornerRadius = 0;
    if (self.cornerRadius <= 0) {
        cornerRadius = size.height/2;
    } else {
        cornerRadius = self.cornerRadius - self.borderWidth/2;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.borderWidth > 0) {
        CGContextSetLineWidth(ctx, self.borderWidth);
        [[UIColor blackColor] setStroke];
    }
    CGMutablePathRef mPath = CGPathCreateMutable();
    
    CGPathAddRoundedRect(mPath, NULL, frame, cornerRadius, cornerRadius);
    CGContextAddPath(ctx, mPath);
    CGPathDrawingMode mode = self.borderWidth > 0 ? kCGPathFillStroke : kCGPathFill;
    CGContextDrawPath(ctx, mode);
    CGPathRelease(mPath);
}

@end

@interface BezierPathVSCGPathViewController ()

@end

@implementation BezierPathVSCGPathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIViewCGPath *v = [[UIViewCGPath alloc] initWithFrame:CGRectMake(0, 100, 20, 20)];
    v.backgroundColor = [UIColor clearColor];
    v.borderWidth = 1;
    v.cornerRadius = 7;
    [self.view addSubview:v];
    
    UIViewCGPath *v1 = [[UIViewCGPath alloc] initWithFrame:CGRectMake(30, 100, 20, 20)];
    v1.backgroundColor = [UIColor clearColor];
    v1.borderWidth = 1;
    v1.cornerRadius = 11;
    [self.view addSubview:v1];
    
    
    UIViewBezierPath *vv = [[UIViewBezierPath alloc] initWithFrame:CGRectMake(0, 140, 20, 20)];
    vv.backgroundColor = [UIColor clearColor];
    vv.borderWidth = 1;
    vv.cornerRadius = 7;
    [self.view addSubview:vv];
    
    UIViewBezierPath *vv1 = [[UIViewBezierPath alloc] initWithFrame:CGRectMake(30, 140, 20, 20)];
    vv1.backgroundColor = [UIColor clearColor];
    vv1.borderWidth = 1;
    vv1.cornerRadius = 8;
    [self.view addSubview:vv1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
