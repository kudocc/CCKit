//
//  ImageIO.m
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageIO.h"
#import "NSString+CCKit.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

// how to get image metadata https://developer.apple.com/library/ios/qa/qa1622/_index.html

@implementation ImageIO

+ (instancetype)sharedImageIO {
    static dispatch_once_t onceToken;
    static ImageIO *imageIO;
    dispatch_once(&onceToken, ^{
        imageIO = [[ImageIO alloc] init];
    });
    return imageIO;
}

- (NSString *)fileDirectory {
    return [[NSString cc_documentPath] stringByAppendingPathComponent:@"imageIO"];
}

@end
