//
//  NSAttributedString+MDLUtil.m
//  CCKitDemo
//
//  Created by rui yuan on 2017/12/3.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "NSAttributedString+MDLUtil.h"


@implementation NSAttributedString (MDLUtil)

+ (instancetype)mdl_attributedStringWithString:(NSString *)string {
    return [self mdl_attributedStringWithString:string attributes:nil];
}

+ (instancetype)mdl_attributedStringWithString:(NSString *)string attributes:(NSDictionary<NSString *,id> *)attributes {
    // 使用self.class保证NSMutableAttributedString继承其可以使用
    return [[self.class alloc] initWithString:string attributes:attributes];
}


+ (instancetype)mdl_attributedStringWithString:(NSString *)string textColor:(UIColor *)color {
    return [self mdl_attributedStringWithString:string textColor:color font:nil];
}

+ (instancetype)mdl_attributedStringWithString:(NSString *)string font:(UIFont *)font {
    return [self mdl_attributedStringWithString:string textColor:nil font:font];
}

+ (instancetype)mdl_attributedStringWithString:(NSString *)string textColor:(UIColor *)color font:(UIFont *)font {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if (color) {
        attributes[NSForegroundColorAttributeName] = color;
    }
    if (font) {
        attributes[NSFontAttributeName] = font;
    }
    return [self mdl_attributedStringWithString:string attributes:attributes];
}


+ (instancetype)mdl_attributedStringWithImage:(UIImage *)image bounds:(CGRect)bounds {
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = bounds;
    id attrString = [self.class attributedStringWithAttachment:attachment];
    return attrString;
}


- (NSDictionary *)mdl_attributes {
    return [self mdl_attributesAtIndex:0];
}
- (NSDictionary *)mdl_attributesAtIndex:(NSUInteger)index {
    if ([self length] > 0) {
        return [self attributesAtIndex:index effectiveRange:NULL];
    } else {
        return NULL;
    }
}


- (UIFont *)mdl_font {
    return [self mdl_fontAtIndex:0];
}
- (UIFont *)mdl_fontAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSFontAttributeName];
    }
    return NULL;
}


- (UIColor *)mdl_color {
    return [self mdl_colorAtIndex:0];
}
- (UIColor *)mdl_colorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSForegroundColorAttributeName];
    }
    return NULL;
}


- (UIColor *)mdl_underlineColor {
    return [self mdl_underlineColorAtIndex:0];
}
- (UIColor *)mdl_underlineColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSUnderlineColorAttributeName];
    }
    return NULL;
}


- (NSUnderlineStyle)mdl_underlineStyle {
    return [self mdl_underlineStyleAtIndex:0];
}
- (NSUnderlineStyle)mdl_underlineStyleAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return [attributes[NSUnderlineStyleAttributeName] integerValue];
    }
    return NSUnderlineStyleNone;
}


- (UIColor *)mdl_strikethroughColor {
    return [self mdl_strikethroughColorAtIndex:0];
}
- (UIColor *)mdl_strikethroughColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSStrikethroughColorAttributeName];
    }
    return NULL;
}


- (NSUnderlineStyle)mdl_strikethroughStyle {
    return [self mdl_strikethroughStyleAtIndex:0];
}
- (NSUnderlineStyle)mdl_strikethroughStyleAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return [attributes[NSStrikethroughStyleAttributeName] integerValue];
    }
    return NSUnderlineStyleNone;
}


- (UIColor *)mdl_bgColor {
    return [self mdl_bgColorAtIndex:0];
}
- (UIColor *)mdl_bgColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSBackgroundColorAttributeName];
    }
    return NULL;
}


- (NSParagraphStyle *)mdl_paragraphStyle {
    return [self mdl_paragraphStyleAtIndex:0];
}
- (NSParagraphStyle *)mdl_paragraphStyleAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self mdl_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSParagraphStyleAttributeName];
    }
    return NULL;
}

@end

@implementation NSMutableAttributedString (MDLUtil)

- (void)mdl_addAttributes:(NSDictionary<NSString *, id> *)attributes {
    [self mdl_addAttributes:attributes overrideOldAttribute:YES];
}

- (void)mdl_addAttributes:(NSDictionary<NSString *, id> *)attributes overrideOldAttribute:(BOOL)overrideOld {
    [self mdl_addAttributes:attributes range:NSMakeRange(0, self.length) overrideOldAttribute:overrideOld];
}

- (void)mdl_addAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range overrideOldAttribute:(BOOL)overrideOld {
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (overrideOld) {
            [self addAttribute:key value:obj range:range];
        } else {
            NSDictionary *attributes = [self mdl_attributesAtIndex:range.location];
            if (!attributes[key]) {
                [self addAttribute:key value:obj range:range];
            }
        }
    }];
}


- (void)mdl_setAttributes:(NSDictionary<NSString *, id> *)attributes {
    [self mdl_setAttributes:attributes range:NSMakeRange(0, self.length)];
}

- (void)mdl_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range {
    [self setAttributes:attributes range:range];
}

#pragma mark - NSFontAttributeName

- (void)mdl_setFont:(UIFont *)font range:(NSRange)range {
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)mdl_setFont:(UIFont *)font {
    [self mdl_setFont:font range:NSMakeRange(0, self.length)];
}

#pragma mark - NSForegroundColorAttributeName

- (void)mdl_setColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)mdl_setColor:(UIColor *)color {
    [self mdl_setColor:color range:NSMakeRange(0, self.length)];
}

#pragma mark - NSUnderlineColorAttributeName

- (void)mdl_setUnderlineColor:(UIColor *)color {
    [self mdl_setUnderlineColor:color range:NSMakeRange(0, self.length)];
}

- (void)mdl_setUnderlineColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSUnderlineColorAttributeName value:color range:range];
}

#pragma mark - NSUnderlineStyleAttributeName

- (void)mdl_setUnderlineStyle:(NSUnderlineStyle)style {
    [self mdl_setUnderlineStyle:style range:NSMakeRange(0, self.length)];
}

- (void)mdl_setUnderlineStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

#pragma mark - NSStrikethroughColorAttributeName

- (void)mdl_setStrikethroughColor:(UIColor *)color {
    [self mdl_setStrikethroughColor:color range:NSMakeRange(0, self.length)];
}

- (void)mdl_setStrikethroughColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSStrikethroughColorAttributeName value:color range:range];
}

#pragma mark - NSStrikethroughStyleAttributeName

- (void)mdl_setStrikethroughStyle:(NSUnderlineStyle)style {
    [self mdl_setStrikethroughStyle:style range:NSMakeRange(0, self.length)];
}

- (void)mdl_setStrikethroughStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self addAttribute:NSStrikethroughStyleAttributeName value:@(style) range:range];
}

#pragma mark - NSBackgroundColorAttributeName

- (void)mdl_setBgColor:(UIColor *)bgColor range:(NSRange)range {
    [self addAttribute:NSBackgroundColorAttributeName value:bgColor range:range];
}

- (void)mdl_setBgColor:(UIColor *)bgColor {
    [self mdl_setBgColor:bgColor range:NSMakeRange(0, self.length)];
}

#pragma mark - ParagraphStyle

#ifndef CCSetParagraphStyle

#define CCSetParagraphStyle(property, value) {\
NSParagraphStyle *style = [self mdl_paragraphStyleAtIndex:range.location];\
if (!style) {\
style = [NSParagraphStyle defaultParagraphStyle];\
}\
NSMutableParagraphStyle *mutableStyle = nil;\
if ([style isKindOfClass:[NSMutableParagraphStyle class]]) {\
mutableStyle = (NSMutableParagraphStyle *)style;\
} else {\
mutableStyle = [style mutableCopy];\
}\
if (mutableStyle) {\
mutableStyle.property = value;\
[self mdl_addAttributes:@{NSParagraphStyleAttributeName: mutableStyle} range:range overrideOldAttribute:YES];\
}\
}\

#endif

- (void)mdl_setAlignment:(NSTextAlignment)alignment {
    [self mdl_setAlignment:alignment range:NSMakeRange(0, self.length)];
}

- (void)mdl_setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    CCSetParagraphStyle(alignment, alignment)
}

- (void)mdl_setFirstLineHeadIndent:(CGFloat)indent {
    [self mdl_setFirstLineHeadIndent:indent range:NSMakeRange(0, self.length)];
}

- (void)mdl_setFirstLineHeadIndent:(CGFloat)indent range:(NSRange)range {
    CCSetParagraphStyle(firstLineHeadIndent, indent)
}

- (void)mdl_setHeadIndent:(CGFloat)indent {
    [self mdl_setHeadIndent:indent range:NSMakeRange(0, self.length)];
}

- (void)mdl_setHeadIndent:(CGFloat)indent range:(NSRange)range {
    CCSetParagraphStyle(headIndent, indent)
}

- (void)mdl_setTailIndent:(CGFloat)indent {
    [self mdl_setTailIndent:indent range:NSMakeRange(0, self.length)];
}

- (void)mdl_setTailIndent:(CGFloat)indent range:(NSRange)range {
    CCSetParagraphStyle(tailIndent, indent)
}

- (void)mdl_setLineBreakModel:(NSLineBreakMode)mode {
    [self mdl_setLineBreakModel:mode range:NSMakeRange(0, self.length)];
}

- (void)mdl_setLineBreakModel:(NSLineBreakMode)mode range:(NSRange)range {
    CCSetParagraphStyle(lineBreakMode, mode)
}

- (void)mdl_setLineSpacing:(CGFloat)spacing {
    [self mdl_setLineSpacing:spacing range:NSMakeRange(0, self.length)];
}

- (void)mdl_setLineSpacing:(CGFloat)spacing range:(NSRange)range {
    CCSetParagraphStyle(lineSpacing, spacing)
}

- (void)mdl_setParagraphSpacing:(CGFloat)spacing {
    [self mdl_setParagraphSpacing:spacing range:NSMakeRange(0, self.length)];
}

- (void)mdl_setParagraphSpacing:(CGFloat)spacing range:(NSRange)range {
    CCSetParagraphStyle(paragraphSpacing, spacing)
}

- (void)mdl_setParagraphSpacingBefore:(CGFloat)spacing {
    [self mdl_setParagraphSpacingBefore:spacing range:NSMakeRange(0, self.length)];
}

- (void)mdl_setParagraphSpacingBefore:(CGFloat)spacing range:(NSRange)range {
    CCSetParagraphStyle(paragraphSpacingBefore, spacing)
}

- (void)mdl_setHyphenationFactor:(float)factor {
    [self mdl_setHyphenationFactor:factor range:NSMakeRange(0, self.length)];
}

- (void)mdl_setHyphenationFactor:(float)factor range:(NSRange)range {
    CCSetParagraphStyle(hyphenationFactor, factor)
}

@end
