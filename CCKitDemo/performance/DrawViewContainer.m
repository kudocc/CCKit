//
//  DrawViewContainer.m
//  demo
//
//  Created by KudoCC on 16/6/22.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "DrawViewContainer.h"
#import "DrawImagePerformanceViewController.h"
#import "UIImage+CCKit.h"

@interface DrawViewContainer ()

@end

@implementation DrawViewContainer

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Origin image",
                        @"Shrink image",
                        @"Shrink image, set cornerRadius & masksToBounds",
                        @"modify image with cornerRadius"];
    self.arrayClass = @[[DrawImagePerformanceViewController class],
                        [DrawImagePerformanceViewController class],
                        [DrawImagePerformanceViewController class],
                        [DrawImagePerformanceViewController class]];
    
    CGSize imageSize = CGSizeMake([DrawImagePerformanceCell imageHeight], [DrawImagePerformanceCell imageHeight]);
    CGFloat cornerRadius = 5.0;
    
    // 为了让性能测试更加明显，我们使用iPhone4的机器，运行在iOS7.1.2的系统上
    // UIImageView 默认的contentMode是UIViewContentModeScaleToFill，所以在resize图片的时候也使用这个contentMode
    
    /**
     fps is very low, below 10...
     */
    
    // origin
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 11; ++i) {
        NSString *imageName = [NSString stringWithFormat:@"image%@.jpg", @(i)];
        UIImage *image = [UIImage imageNamed:imageName];
        [images addObject:image];
    }
    NSDictionary *propertyOriginImage = @{@"images":[images copy]};
    
    /**
     fps: 55 and above
     */
    
    // shrink image
    [images removeAllObjects];
    for (int i = 0; i < 11; ++i) {
        NSString *imageName = [NSString stringWithFormat:@"image%@.jpg", @(i)];
        UIImage *image = [UIImage imageNamed:imageName];
        image = [UIImage cc_resizeImage:image contentMode:UIViewContentModeScaleToFill size:imageSize];
        [images addObject:image];
    }
    NSDictionary *propertyShrinkImage = @{@"images":[images copy]};
    
    /**
     fps is 23, very bad
     */
    
    // shrink image and set cornerRadius & masksToBounds
    NSDictionary *propertyShrinkImageSetCorner = @{@"images":[images copy], @"cornerRadius":@(cornerRadius)};
    
    /**
     fps is 55~59
     */
    // shrink image and modify image with cornerRadius
    [images removeAllObjects];
    for (int i = 0; i < 11; ++i) {
        NSString *imageName = [NSString stringWithFormat:@"image%@.jpg", @(i)];
        UIImage *image = [UIImage imageNamed:imageName];
        image = [image cc_imageWithSize:imageSize cornerRadius:cornerRadius contentMode:UIViewContentModeScaleToFill];
        [images addObject:image];
    }
    NSDictionary *propertyModifiedImage = @{@"images":[images copy]};
    self.arraySetProperty = @[propertyOriginImage, propertyShrinkImage, propertyShrinkImageSetCorner, propertyModifiedImage];
}

@end
