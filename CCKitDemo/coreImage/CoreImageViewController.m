//
//  CoreImageViewController.m
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreImageViewController.h"
#import "BuiltinFilterViewController.h"
#import "CoreImageSubclassCIFilterViewController.h"
#import "BuiltinFilterChainViewController.h"
#import "FaceDetectorViewController.h"
#import "QRCodeViewController.h"

@implementation CoreImageViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"builtin filter",
                        @"builtin chained filter",
                        @"subclass filter",
                        @"face detector",
                        @"qr code"];
    self.arrayClass = @[[BuiltinFilterViewController class],
                        [BuiltinFilterChainViewController class],
                        [CoreImageSubclassCIFilterViewController class],
                        [FaceDetectorViewController class],
                        [QRCodeViewController class]];
    
//    [self logAllFilters];
    [self checkLimits];
}

- (void)logAllFilters {
    NSArray *properties = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@", properties);
    for (NSString *filterName in properties) {
        CIFilter *fltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@", [fltr attributes]);
    }
}

- (void)checkLimits {
    // check the CPU and GPU limit for image size
    NSDictionary *options = @{kCIContextUseSoftwareRenderer:@YES};
    CIContext *softwareContext = [CIContext contextWithOptions:options];
    NSLog(@"software context inputImageMaximumSize:%@, outputImageMaximumSize:%@", NSStringFromCGSize(softwareContext.inputImageMaximumSize), NSStringFromCGSize(softwareContext.outputImageMaximumSize));
    
    options = @{kCIContextUseSoftwareRenderer:@NO};
    CIContext *hardwareContext = [CIContext contextWithOptions:options];
    NSLog(@"hardware context inputImageMaximumSize:%@, outputImageMaximumSize:%@", NSStringFromCGSize(hardwareContext.inputImageMaximumSize), NSStringFromCGSize(hardwareContext.outputImageMaximumSize));
    
    //In iPhone4, the output is below:
    //software context inputImageMaximumSize:{8192, 8192}, outputImageMaximumSize:{8192, 8192}
    //hardware context inputImageMaximumSize:{2048, 2048}, outputImageMaximumSize:{2048, 2048}
    
    //In iPhone6, the output of softare and hardware is the same:
    //
}

@end
