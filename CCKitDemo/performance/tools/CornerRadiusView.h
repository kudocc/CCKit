//
//  CornerRadiusView.h
//  performance
//
//  Created by KudoCC on 16/1/21.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 As set `cornerRadius` of `UIView.layer` and `maskToBounds` reduce performance seriously, so we draw it by ourselves
 
 Note:self.contentMode don't support UIViewContentModeRedraw
 */
@interface CornerRadiusView : UIView

/**
 like image property of UIImageView
 */
@property (nonatomic, strong) UIImage *image;

/**
 like layer.cornerRadius of UIView
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 like layer.borderWidth of UIView
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 like layer.borderColor of UIView
 */
@property (nonatomic, strong) UIColor *borderColor;

@end
