//
//  MDLMessageTextStorage.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/16.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "MDLMessageTextStorage.h"

NSAttributedStringKey MDLMessagetextHighlightedAttributeName = @"MDLMessagetextHighlightedAttributeName";
NSAttributedStringKey MDLMessageTextBackgroundColorAttributeName = @"MDLMessageTextBackgroundColorAttributeName";


@implementation MDLMessageTextHighlightedValue

- (NSDictionary *)attributes {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    if (_backgroundColor) {
        mutableDictionary[MDLMessageTextBackgroundColorAttributeName] = _backgroundColor;
    }
    if (_highlightedColor) {
        mutableDictionary[NSForegroundColorAttributeName] = _highlightedColor;
    }
    return [mutableDictionary copy];
}

@end

@implementation NSMutableAttributedString (MDLMessageTextHighlighted)

- (void)setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(MDLMessageTextHighlightedTapBlock)tapAction {
    [self setHighlightedColor:color bgColor:bgColor range:NSMakeRange(0, self.length) tapAction:tapAction];
}

- (void)setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(MDLMessageTextHighlightedTapBlock)tapAction {
    MDLMessageTextHighlightedValue *value = [MDLMessageTextHighlightedValue new];
    value.enable = NO;
    value.highlightedColor = color;
    value.backgroundColor = bgColor;
    value.tapAction = tapAction;
    [self addAttribute:MDLMessagetextHighlightedAttributeName value:value range:range];
}

@end


@implementation MDLMessageTextStorage

@end
