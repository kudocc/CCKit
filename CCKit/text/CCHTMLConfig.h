//
//  CCHTMLConfig.h
//  demo
//
//  Created by KudoCC on 16/6/13.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TapHyperlinkBlock)(NSString *href);

@interface CCHTMLConfig : NSObject <NSCopying>

/// default is 14.0
@property (nonatomic) CGFloat defaultFontSize;
/// default is black
@property (nonatomic) UIColor *defaultTextColor;

/// 指定一个fontName，全文都使用此font, default is Helvetica
@property (nonatomic) NSString *fontName;

/// default is nil
@property (nonatomic, nullable) UIColor *colorHyperlinkNormal;
/// default is nil
@property (nonatomic, nullable) UIColor *bgcolorHyperlinkNormal;
/// default is nil
@property (nonatomic, nullable) UIColor *colorHyperlinkHighlighted;
/// default is nil
@property (nonatomic, nullable) UIColor *bgcolorHyperlinkHighlighted;
/// 超链接点击的回调
@property (nonatomic, copy, nullable) TapHyperlinkBlock hyperlinkBlock;

+ (CCHTMLConfig *)defaultConfig;

@end

NS_ASSUME_NONNULL_END