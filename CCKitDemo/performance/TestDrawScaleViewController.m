//
//  TestDrawScaleViewController.m
//  performance
//
//  Created by KudoCC on 16/1/22.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "TestDrawScaleViewController.h"

@interface TestDrawScaleViewController ()

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UIImageView *imageView4;

@end

@implementation TestDrawScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    /**
     
     test1 原始图片如果像素不够高，即使scale设置的高，画上去也还是不清晰；
     test2 原始图片像素够高，scale设置的低，画上去不清晰。
     
     */
    
    // img is 132 * 132 px image
    UIImage *img = [UIImage imageNamed:@"avatar"];
    
    // test1, draw a small image into a big area with different scale
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(132.0, 132.0), YES, 1.0);
    [img drawInRect:CGRectMake(0.0, 0.0, 132.0, 132.0)];
    // img draw in 132 * 132 point
    // image1 is 132 * 132 px image
    UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(132.0, 132.0), YES, 2.0);
    [img drawInRect:CGRectMake(0.0, 0.0, 132.0, 132.0)];
    // img draw in 132 * 132 point
    // image2 is 264 * 264 px image
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    
    _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 84.0, 132.0, 132.0)];
    _imageView1.image = image1;
    [self.view addSubview:_imageView1];
    
    _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(132.0, 84.0, 132.0, 132.0)];
    _imageView2.image = image2;
    [self.view addSubview:_imageView2];
    
    
    // test2, draw a image into a equal size (2px with 1point) area with different scale
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0, 64.0), YES, 1.0);
    [img drawInRect:CGRectMake(0.0, 0.0, 64.0, 64.0)];
    // img draw in 132 * 132 point
    // image1 is 132 * 132 px image
    UIImage *image3 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0, 64.0), YES, 2.0);
    [img drawInRect:CGRectMake(0.0, 0.0, 64.0, 64.0)];
    // img draw in 132 * 132 point
    // image2 is 264 * 264 px image
    UIImage *image4 = UIGraphicsGetImageFromCurrentImageContext();
    
    _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, _imageView1.frame.origin.y + _imageView1.frame.size.height, 64.0, 64.0)];
    _imageView3.image = image3;
    [self.view addSubview:_imageView3];
    
    _imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(132.0, _imageView1.frame.origin.y + _imageView1.frame.size.height, 64.0, 64.0)];
    _imageView4.image = image4;
    [self.view addSubview:_imageView4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
