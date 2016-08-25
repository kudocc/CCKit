//
//  QRCodeViewController.m
//  demo
//
//  Created by KudoCC on 16/7/14.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "QRCodeViewController.h"
#import "UIImage+CCKit.h"

@implementation QRCodeViewController {
    UIImageView *_imageView;
}

- (void)initView {
    [super initView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64.0, ScreenWidth, ScreenWidth)];
    [self.view addSubview:_imageView];
    
    CGSize size = _imageView.size;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *qrString = @"http://www.baidu.com";
        UIImage *image = [UIImage cc_imageWithQRCodeString:qrString imageSize:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = image;
        });
    });
}

@end
