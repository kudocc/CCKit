//
//  ImageViewPerformanceViewController.h
//  demo
//
//  Created by KudoCC on 16/6/22.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

@interface ImageViewPerformanceViewController : BaseViewController

@property (nonatomic) NSArray *images;
@property (nonatomic) CGFloat cornerRadius;

@end

@interface ImageViewPerformanceCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView1;
@property (nonatomic, strong) UIImageView *imgView2;
@property (nonatomic, strong) UIImageView *imgView3;

+ (CGFloat)cellHeight;
+ (CGFloat)imageHeight;

@end
