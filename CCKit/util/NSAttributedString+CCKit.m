//
//  NSAttributedString+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSAttributedString+CCKit.h"
#import "CCTextRunDelegate.h"

@implementation NSAttributedString (CCKit)

+ (instancetype)cc_attributedStringWithString:(NSString *)string {
    return [self cc_attributedStringWithString:string attributes:nil];
}

+ (instancetype)cc_attributedStringWithString:(NSString *)string attributes:(NSDictionary<NSString *,id> *)attributes {
    return [[self.class alloc] initWithString:string attributes:attributes];
}


+ (instancetype)cc_attributedStringWithString:(NSString *)string textColor:(UIColor *)color {
    return [self cc_attributedStringWithString:string textColor:color font:nil];
}

+ (instancetype)cc_attributedStringWithString:(NSString *)string font:(UIFont *)font {
    return [self cc_attributedStringWithString:string textColor:nil font:font];
}

+ (instancetype)cc_attributedStringWithString:(NSString *)string textColor:(UIColor *)color font:(UIFont *)font {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if (color) {
        attributes[NSForegroundColorAttributeName] = color;
    }
    if (font) {
        attributes[NSFontAttributeName] = font;
    }
    return [self cc_attributedStringWithString:string attributes:attributes];
}


+ (instancetype)cc_attributedStringWithImage:(UIImage *)image bounds:(CGRect)bounds {
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = bounds;
    NSAttributedString *attrString = [NSAttributedString attributedStringWithAttachment:attachment];
    return attrString;
}


- (NSDictionary *)cc_attributes {
    return [self cc_attributesAtIndex:0];
}
- (NSDictionary *)cc_attributesAtIndex:(NSUInteger)index {
    if ([self length] > 0) {
        return [self attributesAtIndex:index effectiveRange:NULL];
    } else {
        return NULL;
    }
}


- (UIFont *)cc_font {
    return [self cc_fontAtIndex:0];
}
- (UIFont *)cc_fontAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSFontAttributeName];
    }
    return NULL;
}


- (UIColor *)cc_color {
    return [self cc_colorAtIndex:0];
}
- (UIColor *)cc_colorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSForegroundColorAttributeName];
    }
    return NULL;
}


- (UIColor *)cc_underlineColor {
    return [self cc_underlineColorAtIndex:0];
}
- (UIColor *)cc_underlineColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSUnderlineColorAttributeName];
    }
    return NULL;
}


- (NSUnderlineStyle)cc_underlineStyle {
    return [self cc_underlineStyleAtIndex:0];
}
- (NSUnderlineStyle)cc_underlineStyleAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return [attributes[NSUnderlineStyleAttributeName] integerValue];
    }
    return NSUnderlineStyleNone;
}


- (UIColor *)cc_strikethroughColor {
    return [self cc_strikethroughColorAtIndex:0];
}
- (UIColor *)cc_strikethroughColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSStrikethroughColorAttributeName];
    }
    return NULL;
}


- (NSUnderlineStyle)cc_strikethroughStyle {
    return [self cc_strikethroughStyleAtIndex:0];
}
- (NSUnderlineStyle)cc_strikethroughStyleAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return [attributes[NSStrikethroughStyleAttributeName] integerValue];
    }
    return NSUnderlineStyleNone;
}


- (UIColor *)cc_bgColor {
    return [self cc_bgColorAtIndex:0];
}
- (UIColor *)cc_bgColorAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSBackgroundColorAttributeName];
    }
    return NULL;
}


- (NSParagraphStyle *)cc_paragraphStyle {
    return [self cc_paragraphStyleAtIndex:0];
}
- (NSParagraphStyle *)cc_paragraphStyleAtIndex:(NSUInteger)index {
    NSDictionary *attributes = [self cc_attributesAtIndex:index];
    if (attributes) {
        return attributes[NSParagraphStyleAttributeName];
    }
    return NULL;
}

#pragma mark - attachment

+ (NSAttributedString *)cc_attachmentStringWithContent:(id)content contentMode:(UIViewContentMode)contentMode contentSize:(CGSize)contentSize alignToFont:(UIFont *)font attachmentPosition:(CCTextAttachmentPosition)position {
    CGFloat ascent, descent, width;
    width = contentSize.width;
    CGSize size = contentSize;
    switch (position) {
        case CCTextAttachmentPositionTop:
            ascent = font.ascender;
            descent = size.height - ascent;
            break;
        case CCTextAttachmentPositionBottom:
            descent = -font.descender;
            ascent = size.height-descent;
            break;
        default:
            ascent = font.ascender + floor((size.height - font.ascender + font.descender)/2);
            ascent = ascent > 0 ? ascent : 0;
            descent = size.height - ascent;
            break;
    }
    return [self cc_attachmentStringWithContent:content contentMode:contentMode width:width ascent:ascent descent:descent];
}

+ (NSAttributedString *)cc_attachmentStringWithContent:(id)content contentMode:(UIViewContentMode)contentMode width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:CCAttachmentCharacter];
    
    CCTextAttachment *attachment = [CCTextAttachment textAttachmentWithContent:content];
    attachment.content = content;
    attachment.contentMode = contentMode;
    
    CCTextRunDelegate *runDelegate = [[CCTextRunDelegate alloc] init];
    runDelegate.width = width;
    runDelegate.ascent = ascent;
    runDelegate.descent = descent;
    CTRunDelegateRef ctRunDelegate = [runDelegate createCTRunDelegateRef];
    [attrString addAttributes:@{CCAttachmentAttributeName:attachment, (__bridge id)kCTRunDelegateAttributeName: (__bridge id)ctRunDelegate} range:NSMakeRange(0, [attrString length])];
    CFRelease(ctRunDelegate);
    return attrString;
}

@end

@implementation NSMutableAttributedString (CCKit)

- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes {
    [self cc_addAttributes:attributes overrideOldAttribute:YES];
}

- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes overrideOldAttribute:(BOOL)overrideOld {
    [self cc_addAttributes:attributes range:NSMakeRange(0, self.length) overrideOldAttribute:overrideOld];
}

- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range overrideOldAttribute:(BOOL)overrideOld {
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (overrideOld) {
            [self addAttribute:key value:obj range:range];
        } else {
            NSDictionary *attributes = [self cc_attributesAtIndex:range.location];
            if (!attributes[key]) {
                [self addAttribute:key value:obj range:range];
            }
        }
    }];
}


- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes {
    [self cc_setAttributes:attributes range:NSMakeRange(0, self.length)];
}

- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range {
    [self setAttributes:attributes range:range];
}

#pragma mark - NSFontAttributeName

- (void)cc_setFont:(UIFont *)font range:(NSRange)range {
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)cc_setFont:(UIFont *)font {
    [self cc_setFont:font range:NSMakeRange(0, self.length)];
}

#pragma mark - NSForegroundColorAttributeName

- (void)cc_setColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)cc_setColor:(UIColor *)color {
    [self cc_setColor:color range:NSMakeRange(0, self.length)];
}

#pragma mark - NSUnderlineColorAttributeName

- (void)cc_setUnderlineColor:(UIColor *)color {
    [self cc_setUnderlineColor:color range:NSMakeRange(0, self.length)];
}

- (void)cc_setUnderlineColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSUnderlineColorAttributeName value:color range:range];
}

#pragma mark - NSUnderlineStyleAttributeName

- (void)cc_setUnderlineStyle:(NSUnderlineStyle)style {
    [self cc_setUnderlineStyle:style range:NSMakeRange(0, self.length)];
}

- (void)cc_setUnderlineStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

#pragma mark - NSStrikethroughColorAttributeName

- (void)cc_setStrikethroughColor:(UIColor *)color {
    [self cc_setStrikethroughColor:color range:NSMakeRange(0, self.length)];
}

- (void)cc_setStrikethroughColor:(UIColor *)color range:(NSRange)range {
    [self addAttribute:NSStrikethroughColorAttributeName value:color range:range];
}

#pragma mark - NSStrikethroughStyleAttributeName

- (void)cc_setStrikethroughStyle:(NSUnderlineStyle)style {
    [self cc_setStrikethroughStyle:style range:NSMakeRange(0, self.length)];
}

- (void)cc_setStrikethroughStyle:(NSUnderlineStyle)style range:(NSRange)range {
    [self addAttribute:NSStrikethroughStyleAttributeName value:@(style) range:range];
}

#pragma mark - CCBackgroundColorAttributeName

- (void)cc_setBgColor:(UIColor *)bgColor range:(NSRange)range {
    [self addAttribute:CCBackgroundColorAttributeName value:bgColor range:range];
}

- (void)cc_setBgColor:(UIColor *)bgColor {
    [self cc_setBgColor:bgColor range:NSMakeRange(0, self.length)];
}

#pragma mark - CCHighlightedAttributeName

- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(CCTapActionBlock)tapAction {
    CCTextHighlighted *hi = [[CCTextHighlighted alloc] init];
    hi.highlightedColor = color;
    hi.bgColor = bgColor;
    hi.tapAction = tapAction;
    [self addAttribute:CCHighlightedAttributeName value:hi range:NSMakeRange(0, self.length)];
}

- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(CCTapActionBlock)tapAction {
    CCTextHighlighted *hi = [[CCTextHighlighted alloc] init];
    hi.highlightedColor = color;
    hi.bgColor = bgColor;
    hi.tapAction = tapAction;
    [self addAttribute:CCHighlightedAttributeName value:hi range:range];
}

#pragma mark - Core Text Attribute

- (void)cc_setSuperscript:(NSInteger)superScript {
    [self cc_setSuperscript:superScript range:NSMakeRange(0, self.length)];
}

- (void)cc_setSuperscript:(NSInteger)superScript range:(NSRange)range {
    [self addAttribute:(__bridge id)kCTSuperscriptAttributeName value:@(superScript) range:range];
}

#pragma mark - ParagraphStyle

#ifndef CCSetParagraphStyle

#define CCSetParagraphStyle(property, value) {\
    NSParagraphStyle *style = [self cc_paragraphStyleAtIndex:range.location];\
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
        [self cc_addAttributes:@{NSParagraphStyleAttributeName: mutableStyle} range:range overrideOldAttribute:YES];\
    }\
}\

#endif

- (void)cc_setAlignment:(NSTextAlignment)alignment {
    [self cc_setAlignment:alignment range:NSMakeRange(0, self.length)];
}

- (void)cc_setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    CCSetParagraphStyle(alignment, alignment)
}

- (void)cc_setFirstLineHeadIndent:(CGFloat)indent {
    [self cc_setFirstLineHeadIndent:indent range:NSMakeRange(0, self.length)];
}

- (void)cc_setFirstLineHeadIndent:(CGFloat)indent range:(NSRange)range {
    CCSetParagraphStyle(firstLineHeadIndent, indent)
}

- (void)cc_setHeadIndent:(CGFloat)indent {
    [self cc_setHeadIndent:indent range:NSMakeRange(0, self.length)];
}

- (void)cc_setHeadIndent:(CGFloat)indent range:(NSRange)range {
    CCSetParagraphStyle(headIndent, indent)
}

- (void)cc_setTailIndent:(CGFloat)indent {
    [self cc_setTailIndent:indent range:NSMakeRange(0, self.length)];
}

- (void)cc_setTailIndent:(CGFloat)indent range:(NSRange)range {
    CCSetParagraphStyle(tailIndent, indent)
}

- (void)cc_setLineBreakModel:(NSLineBreakMode)mode {
    [self cc_setLineBreakModel:mode range:NSMakeRange(0, self.length)];
}

- (void)cc_setLineBreakModel:(NSLineBreakMode)mode range:(NSRange)range {
    CCSetParagraphStyle(lineBreakMode, mode)
}

- (void)cc_setLineSpacing:(CGFloat)spacing {
    [self cc_setLineSpacing:spacing range:NSMakeRange(0, self.length)];
}

- (void)cc_setLineSpacing:(CGFloat)spacing range:(NSRange)range {
    CCSetParagraphStyle(lineSpacing, spacing)
}

- (void)cc_setParagraphSpacing:(CGFloat)spacing {
    [self cc_setParagraphSpacing:spacing range:NSMakeRange(0, self.length)];
}

- (void)cc_setParagraphSpacing:(CGFloat)spacing range:(NSRange)range {
    CCSetParagraphStyle(paragraphSpacing, spacing)
}

- (void)cc_setParagraphSpacingBefore:(CGFloat)spacing {
    [self cc_setParagraphSpacingBefore:spacing range:NSMakeRange(0, self.length)];
}

- (void)cc_setParagraphSpacingBefore:(CGFloat)spacing range:(NSRange)range {
    CCSetParagraphStyle(paragraphSpacingBefore, spacing)
}

- (void)cc_setHyphenationFactor:(float)factor {
    [self cc_setHyphenationFactor:factor range:NSMakeRange(0, self.length)];
}

- (void)cc_setHyphenationFactor:(float)factor range:(NSRange)range {
    CCSetParagraphStyle(hyphenationFactor, factor)
}

#pragma mark - Attachment

- (void)cc_setAttachmentWithContent:(id)content
                        contentMode:(UIViewContentMode)contentMode
                        contentSize:(CGSize)contentSize alignToFont:(UIFont *)font
                 attachmentPosition:(CCTextAttachmentPosition)position range:(NSRange)range {
    CGFloat ascent, descent, width;
    width = contentSize.width;
    CGSize size = contentSize;
    switch (position) {
        case CCTextAttachmentPositionTop:
            ascent = font.ascender;
            descent = size.height - ascent;
            break;
        case CCTextAttachmentPositionBottom:
            descent = -font.descender;
            ascent = size.height-descent;
            break;
        default:
            ascent = font.ascender + floor((size.height - font.ascender + font.descender)/2);
            ascent = ascent > 0 ? ascent : 0;
            descent = size.height - ascent;
            break;
    }
    return [self cc_setAttachmentStringWithContent:content contentMode:contentMode width:width ascent:ascent descent:descent range:range];
}

- (void)cc_setAttachmentStringWithContent:(id)content
                              contentMode:(UIViewContentMode)contentMode
                                    width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent range:(NSRange)range {
    CCTextAttachment *attachment = [CCTextAttachment textAttachmentWithContent:content];
    attachment.content = content;
    attachment.contentMode = contentMode;
    
    CCTextRunDelegate *runDelegate = [[CCTextRunDelegate alloc] init];
    runDelegate.width = width;
    runDelegate.ascent = ascent;
    runDelegate.descent = descent;
    CTRunDelegateRef ctRunDelegate = [runDelegate createCTRunDelegateRef];
    [self addAttributes:@{CCAttachmentAttributeName:attachment, (__bridge id)kCTRunDelegateAttributeName: (__bridge id)ctRunDelegate} range:range];
    CFRelease(ctRunDelegate);
}

@end
