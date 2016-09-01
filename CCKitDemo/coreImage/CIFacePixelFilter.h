//
//  CIFacePixelFilter.h
//  CCKitDemo
//
//  Created by KudoCC on 16/8/29.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIFacePixelFilter : CIFilter

@property (nonatomic) CIImage *inputImage;
@property (nonatomic, weak) CIContext *context;
@end
