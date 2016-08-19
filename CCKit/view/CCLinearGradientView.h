//
//  UILinearGradientView.h
//  VOV
//
//  Created by KudoCC on 15/8/19.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CCLinerGradientViewAxis) {
    CCLinerGradientViewAxisX,   // 沿着X轴
    CCLinerGradientViewAxisY    // 沿着Y轴
};

@interface CCLinearGradientView : UIView

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors axis:(CCLinerGradientViewAxis)axis;

@end
