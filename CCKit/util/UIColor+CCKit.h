//
//  UIColor+CCKit.h
//  demo
//
//  Created by KudoCC on 16/5/12.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CCKit)

// from 0 ~ 255, alpha default is 255
+ (UIColor *)cc_colorWithRed:(int)red green:(int)green blue:(int)blue;
+ (UIColor *)cc_colorWithRed:(int)red green:(int)green blue:(int)blue alpha:(int)alpha;

+ (UIColor *)cc_opaqueColorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)cc_colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

@end
