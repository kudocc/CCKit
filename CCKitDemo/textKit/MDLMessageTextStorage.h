//
//  MDLMessageTextStorage.h
//  CCKitDemo
//
//  Created by kudocc on 2017/10/16.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *MDLMessagetextHighlightedAttributeName;
extern NSString *MDLMessageTextBackgroundColorAttributeName;

typedef void(^MDLMessageTextHighlightedTapBlock)(NSRange range);

@interface MDLMessageTextHighlightedValue : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic) UIColor *highlightedColor;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) MDLMessageTextHighlightedTapBlock tapAction;

- (NSDictionary *)attributes;

@end


@interface NSMutableAttributedString (MDLMessageTextHighlighted)

- (void)setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(MDLMessageTextHighlightedTapBlock)tapAction;
- (void)setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(MDLMessageTextHighlightedTapBlock)tapAction;

@end

@interface MDLMessageTextStorage : NSTextStorage

@end
