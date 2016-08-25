//
//  LineViewController.m
//  demo
//
//  Created by KudoCC on 16/6/14.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "LineViewController.h"
#import "NSAttributedString+CCKit.h"

@interface LineView : UIView {
    NSUnderlineStyle underLine;
    /*
     NSUnderlineStyleNone                                    = 0x00,
     NSUnderlineStyleSingle                                  = 0x01,
     NSUnderlineStyleThick NS_ENUM_AVAILABLE(10_0, 7_0)      = 0x02,
     NSUnderlineStyleDouble NS_ENUM_AVAILABLE(10_0, 7_0)     = 0x09,
     
     NSUnderlinePatternSolid NS_ENUM_AVAILABLE(10_0, 7_0)      = 0x0000,
     NSUnderlinePatternDot NS_ENUM_AVAILABLE(10_0, 7_0)        = 0x0100,
     NSUnderlinePatternDash NS_ENUM_AVAILABLE(10_0, 7_0)       = 0x0200,
     NSUnderlinePatternDashDot NS_ENUM_AVAILABLE(10_0, 7_0)    = 0x0300,
     NSUnderlinePatternDashDotDot*/
}

@end

#define DrawLineAtXY {\
    CGContextMoveToPoint(context, x, y);\
    CGContextAddLineToPoint(context, x+width, y);\
    CGContextStrokePath(context);\
}

@implementation LineView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat y = 100;
    CGFloat paddingY = 10;
    CGFloat x = 10;
    CGFloat width = 100;
    CGContextSetLineWidth(context, 1);
    // draw solid line
    DrawLineAtXY
    
    y += paddingY;
    // draw NSUnderlinePatternDot
    CGFloat patternDot[] = {3, 3};
    CGContextSetLineDash(context, 0, patternDot, 2);
    DrawLineAtXY
    
    y += paddingY;
    // draw NSUnderlinePatternDash
    CGFloat patternDash[] = {10, 5};
    CGContextSetLineDash(context, 0, patternDash, 2);
    DrawLineAtXY
    
    y += paddingY;
    // draw NSUnderlinePatternDashDot
    CGFloat patternDashDot[] = {10, 3, 3, 3};
    CGContextSetLineDash(context, 0, patternDashDot, sizeof(patternDashDot)/sizeof(CGFloat));
    DrawLineAtXY
    
    y += paddingY;
    // draw NSUnderlinePatternDashDotDot
    CGFloat patternDashDotDot[] = {10, 3, 3, 3, 3, 3};
    CGContextSetLineDash(context, 0, patternDashDotDot, sizeof(patternDashDotDot)/sizeof(CGFloat));
    DrawLineAtXY
}

@end

@implementation LineViewController

- (void)initView {
    [super initView];
    
    NSMutableAttributedString *solid = [[NSMutableAttributedString alloc] initWithString:@"ooooo      do it pppp"];
    
    NSMutableAttributedString *dot = [solid mutableCopy];
    [dot cc_setUnderlineStyle:NSUnderlineStyleSingle|NSUnderlinePatternDot];
    
    NSMutableAttributedString *dash = [solid mutableCopy];
    [dash cc_setUnderlineStyle:NSUnderlineStyleSingle|NSUnderlinePatternDash];
    
    NSMutableAttributedString *dashDot = [solid mutableCopy];
    [dashDot cc_setUnderlineStyle:NSUnderlineStyleDouble|NSUnderlinePatternDashDot];
    
    NSMutableAttributedString *dashDotDot = [solid mutableCopy];
    [dashDotDot cc_setUnderlineStyle:NSUnderlineStyleThick|NSUnderlinePatternDashDotDot];
    
    NSMutableAttributedString *word = [solid mutableCopy];
    [word cc_setUnderlineStyle:NSUnderlineStyleSingle|NSUnderlinePatternDashDotDot|NSUnderlineByWord];
    
    [solid appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [solid appendAttributedString:dot];
    [solid appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [solid appendAttributedString:dash];
    [solid appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [solid appendAttributedString:dashDot];
    [solid appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [solid appendAttributedString:dashDotDot];
    [solid appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    [solid appendAttributedString:word];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, ScreenWidth, ScreenHeight-280)];
    label.attributedText = [solid copy];
    [self.view addSubview:label];
    label.numberOfLines = 0;
}

- (void)loadView {
    LineView *v = [[LineView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.view = v;
}

@end
