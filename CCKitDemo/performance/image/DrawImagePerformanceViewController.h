//
//  DrawImagePerformanceViewController.h
//  demo
//
//  Created by KudoCC on 16/6/22.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

@interface DrawImagePerformanceViewController : BaseViewController

@property (nonatomic) NSArray *images;
@property (nonatomic) CGFloat cornerRadius;

@end

@interface DrawView : UIView
@property (nonatomic) UIImage *image;
@end

@interface DrawImagePerformanceCell : UITableViewCell

@property (nonatomic, strong) DrawView *imgView1;
@property (nonatomic, strong) DrawView *imgView2;
@property (nonatomic, strong) DrawView *imgView3;

+ (CGFloat)cellHeight;
+ (CGFloat)imageHeight;

@end
