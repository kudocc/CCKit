//
//  TextKitViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/14.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKitViewController.h"
#import "TextKit_ConstructViewController.h"
#import "TextKit1Storage2LayoutManagerViewController.h"
#import "TextKit1Storage2ContainerViewController.h"
#import "TextKitCustomTextViewLayoutViewController.h"
#import "TextKitLayoutManagerViewController.h"
#import "TextKitLabelDemoViewController.h"
#import "TextKitLabelDragViewController.h"
#import "TextKitTextViewViewController.h"


@interface TextKitViewController ()

@end

@implementation TextKitViewController

- (void)initView {
    [super initView];
    
    UIFont *f0 = [UIFont systemFontOfSize:10];
    UIFont *f1 = [UIFont systemFontOfSize:20];
    UIFont *f2 = [UIFont fontWithName:@"Avenir Next" size:10];
    UIFont *f3 = [UIFont fontWithName:@"Avenir Next" size:20];
    NSLog(@"%f, %f, %f, %f", f0.leading, f1.leading, f2.leading, f3.leading);
    
    self.arrayTitle = @[@"TextKit label", @"TextKit label drag", @"TextKit TextView", @"TextView", @"Construct TextKit", @"One storage with 2 layout manager", @"One storage with 2 container", @"LayoutManager"];
    self.arrayClass = @[[TextKitLabelDemoViewController class],
                        [TextKitLabelDragViewController class],
                        [TextKitCustomTextViewLayoutViewController class],
                        [TextKitTextViewViewController class],
                        [TextKit_ConstructViewController class],
                        [TextKit1Storage2LayoutManagerViewController class],
                        [TextKit1Storage2ContainerViewController class],
                        [TextKitLayoutManagerViewController class],
                        ];
}

@end
