//
//  CoreTextExclusivePathViewController.m
//  demo
//
//  Created by KudoCC on 16/6/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreTextExclusivePathViewController.h"
#import "CCLabel.h"
#import "NSAttributedString+CCKit.h"

@interface EllipseView : UIView
@end

@implementation EllipseView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextStrokeEllipseInRect(context, self.bounds);
}

- (UIBezierPath *)path {
    return [UIBezierPath bezierPathWithOvalInRect:self.bounds];
}

@end

@implementation CoreTextExclusivePathViewController {
    EllipseView *_ellipseView;
    CCLabel *_label;
    NSMutableAttributedString *_attr;
}

- (void)initView {
    [super initView];
    
    _label = [[CCLabel alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:_label];
    _label.asyncDisplay = NO;
    _label.verticleAlignment = CCTextVerticalAlignmentTop;
    _label.contentInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    
    _ellipseView = [[EllipseView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:_ellipseView];
    _ellipseView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [_ellipseView addGestureRecognizer:pan];
    
    NSString *str = @"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD";
    _attr = [[NSMutableAttributedString alloc] initWithString:str];
    [_attr cc_setColor:[UIColor blackColor]];
    [_attr cc_setFont:[UIFont systemFontOfSize:14]];
    _label.attributedText = _attr;
    
    [self updateLayout];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gr {
    CGPoint p = [gr locationInView:self.view];
    _ellipseView.center = p;
    [self updateLayout];
}

- (void)updateLayout {
    CGPoint p = [_label convertPoint:CGPointZero fromView:_ellipseView];
    UIBezierPath *path = [_ellipseView path];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(p.x, p.y);
    [path applyTransform:transform];
    _label.exclusionPaths = @[path];
}

@end
