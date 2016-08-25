//
//  ImageMaskViewController.h
//  ImageMask
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

@interface ImageMaskViewController : BaseViewController

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageViewOri;

@property (nonatomic, strong) UIImageView *imageViewMaskWithImage;
@property (nonatomic, strong) UIImageView *imageViewMaskWithImageMask;

@property (nonatomic, strong) UIImageView *imageViewResultMaskWithImage;
@property (nonatomic, strong) UIImageView *imageViewResultMaskWithImageMask;

@property (nonatomic, strong) UIImageView *imageViewResultMaskWithColor;

@end
