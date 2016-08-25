//
//  ImagePickerViewController.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImagePickerViewController.h"

@interface ImagePickerViewController ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation ImagePickerViewController

- (void)setImage:(UIImage *)image {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.view addSubview:_imageView];
    }
    
    CGSize imageSize = image.size;
    imageSize = CGSizeMake(ScreenWidth, ScreenWidth);
    _imageView.image = image;
    _imageView.center = self.view.center;
    
    if (imageSize.width > ScreenWidth ||
        imageSize.height > ScreenHeightNoTop) {
        // need shrink
        CGFloat scaleW = imageSize.width/ScreenWidth;
        CGFloat scaleH = imageSize.height/ScreenHeightNoTop;
        CGSize size;
        if (scaleW > scaleH) {
            size = CGSizeMake(ScreenWidth, floor(imageSize.height/scaleW));
        } else {
            size = CGSizeMake(floor(imageSize.width/scaleH), ScreenHeightNoTop);
        }
        _imageView.size = size;
    } else {
        _imageView.size = imageSize;
    }
    _imageView.image = image;
    _imageView.center = self.view.center;
}

- (CGRect)imageFrame {
    return _imageView.frame;
}

@end
