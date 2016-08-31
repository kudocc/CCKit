//
//  ViewController.m
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "Quartz2DViewController.h"
#import "ImageMaskViewController.h"
#import "PathViewController.h"
#import "PatternViewController.h"
#import "CoordinateViewController.h"
#import "ShadowGradientsViewController.h"
#import "ImageBlendViewController.h"
#import "LineViewController.h"

@interface Quartz2DViewController ()

@end

@implementation Quartz2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arrayTitle = @[@"Line", @"ImageMask", @"Path", @"Colored & Stencil Pattern", @"Coordinate Test", @"Shadow & Gradient", @"Image Blend"];
    self.arrayClass = @[[LineViewController class],
                        [ImageMaskViewController class],
                        [PathViewController class],
                        [PatternViewController class],
                        [CoordinateViewController class],
                        [ShadowGradientsViewController class],
                        [ImageBlendViewController class]];
}

@end
