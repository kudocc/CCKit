//
//  ImageViewContainer.m
//  demo
//
//  Created by KudoCC on 16/6/22.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageViewContainer.h"
#import "ImageViewPerformanceViewController.h"
#import "UIImage+CCKit.h"

/**
 在iPhone4上, masksToBounds==YES -> 帧率12左右；masksToBounds == NO -> 帧率将近30，应该是UIImageView对图片解压缩和缩放比较耗费cpu
 为了不让UIImageView在缩放上耗费时间，我把contentMode改成center，帧率将近40，说明确实有影响；
 下面要将图片提前解压缩，看一下是不是也有影响，发现貌似没什么影响，仍然是接近30的值。
 另外发现一个有趣的，如果只设置borderColor和borderWidth，那么帧率50左右；如果只设置cornerRadius并且masksToBounds为NO，帧率50以上。与上面的结论对比，看来带圆角的border也会造成一些性能损耗，即使不产生离屏渲染；如果横向对比，设置border会有性能损耗。
 
 在iPhone6上masksToBounds为YES，帧率接近40；masksToBounds为NO，帧率接近60。
 */

@interface ImageViewContainer ()

@end

@implementation ImageViewContainer

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Origin image in UIImageView",
                        @"Shrink image in UIImageView",
                        @"Shrink image in UIImageView, set cornerRadius & masksToBounds",
                        @"modify image with cornerRadius and set in UIImageView"];
    self.arrayClass = @[[ImageViewPerformanceViewController class],
                        [ImageViewPerformanceViewController class],
                        [ImageViewPerformanceViewController class],
                        [ImageViewPerformanceViewController class]];
    
    CGSize imageSize = CGSizeMake([ImageViewPerformanceCell imageHeight], [ImageViewPerformanceCell imageHeight]);
    CGFloat cornerRadius = 5.0;
    
    // 为了让性能测试更加明显，我们使用iPhone4的机器，运行在iOS7.1.2的系统上
    // UIImageView 默认的contentMode是UIViewContentModeScaleToFill，所以在resize图片的时候也使用这个contentMode
    
    /**
     With origin image, fps is near 60, 55~59
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
     Almost the same as origin, but I believe if the origin image is very big, the result will be different.
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
