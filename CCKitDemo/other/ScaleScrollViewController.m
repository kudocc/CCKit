//
//  ScaleScrollViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/23.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ScaleScrollViewController.h"
#import "UIImage+CCKit.h"

@interface ScaleScrollViewController () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UIImage *imageHigh;
@property (nonatomic) UIImage *imageLow;

@end

@implementation ScaleScrollViewController

- (void)initView {
    [self showRightBarButtonItemWithName:@"switch image quality"];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 2.0;
    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
//    [_imageView addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:doubleTap];
//    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    _imageHigh = [UIImage imageNamed:@"3264_2448.jpg"];
    _imageLow = [_imageHigh cc_imageWithSize:CGSizeMake(_imageView.width, _imageView.height) cornerRadius:0];
    
    _imageView.image = _imageLow;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _scrollView.contentSize = _scrollView.bounds.size;
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    CGPoint p = [tap locationInView:_scrollView];
    CGSize size = CGSizeMake(44, 44);
    CGRect rect = CGRectMake(p.x-size.width/2, p.y-size.height/2, size.width, size.height);
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        [_scrollView zoomToRect:rect animated:YES];
    }
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    if (_imageView.image == _imageLow) {
        _imageView.image = _imageHigh;
        _scrollView.maximumZoomScale = 3.0;
        self.title = @"high";
    } else {
        _imageView.image = _imageLow;
        _scrollView.maximumZoomScale = 2.0;
        self.title = @"low";
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

@end
