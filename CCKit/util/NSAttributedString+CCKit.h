//
//  NSAttributedString+CCKit.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCTextDefine.h"

@interface NSAttributedString (CCKit)

+ (instancetype)cc_attributedStringWithString:(NSString *)string;
+ (instancetype)cc_attributedStringWithString:(NSString *)string attributes:(NSDictionary<NSString *,id> *)attributes;

/// convenient methods to initialize NSAttributedString with textColor and font
+ (instancetype)cc_attributedStringWithString:(NSString *)string textColor:(UIColor *)color;
+ (instancetype)cc_attributedStringWithString:(NSString *)string font:(UIFont *)font;
+ (instancetype)cc_attributedStringWithString:(NSString *)string textColor:(UIColor *)color font:(UIFont *)font;

+ (instancetype)cc_attributedStringWithImage:(UIImage *)image bounds:(CGRect)bounds;

/// get the attributes of the first character
- (NSDictionary *)cc_attributes;
- (NSDictionary *)cc_attributesAtIndex:(NSUInteger)index;

/// get the font of the first character
- (UIFont *)cc_font;
- (UIFont *)cc_fontAtIndex:(NSUInteger)index;

/// get the color of the first character
- (UIColor *)cc_color;
- (UIColor *)cc_colorAtIndex:(NSUInteger)index;

/// get the underline color of the first character
- (UIColor *)cc_underlineColor;
- (UIColor *)cc_underlineColorAtIndex:(NSUInteger)index;

/// get the underline style of the first character
- (NSUnderlineStyle)cc_underlineStyle;
- (NSUnderlineStyle)cc_underlineStyleAtIndex:(NSUInteger)index;

/// get the strikethrough color of the first character
- (UIColor *)cc_strikethroughColor;
- (UIColor *)cc_strikethroughColorAtIndex:(NSUInteger)index;

/// get the strikethrough style of the first character
- (NSUnderlineStyle)cc_strikethroughStyle;
- (NSUnderlineStyle)cc_strikethroughStyleAtIndex:(NSUInteger)index;

/// get the background color of the first character
- (UIColor *)cc_bgColor;
- (UIColor *)cc_bgColorAtIndex:(NSUInteger)index;

/// get the NSParagrahStyle
- (NSParagraphStyle *)cc_paragraphStyle;
- (NSParagraphStyle *)cc_paragraphStyleAtIndex:(NSUInteger)index;


+ (instancetype)cc_attachmentStringWithContent:(id)content
                                   contentMode:(UIViewContentMode)contentMode
                                   contentSize:(CGSize)contentSize alignToFont:(UIFont *)font
                            attachmentPosition:(CCTextAttachmentPosition)position;

+ (instancetype)cc_attachmentStringWithContent:(id)content
                                   contentMode:(UIViewContentMode)contentMode
                                         width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent;

@end

@interface NSMutableAttributedString (CCKit)

/// call `cc_addAttributes:overrideOldAttribute:` with overrideOld=YES.
- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes;
/// call `cc_addAttributes:range:overrideOldAttribute:` with range=NSMakeRange(0, self.length)
- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes overrideOldAttribute:(BOOL)overrideOld;
/// for each attribute and value in attributes, call `addAttribute:value:range`, if overideOld is NO and there is a value at range.location, do nothing on that attribute.
- (void)cc_addAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range overrideOldAttribute:(BOOL)overrideOld;

- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes;
/// call `setAttributes:range:`
- (void)cc_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range;

- (void)cc_setFont:(UIFont *)font;
- (void)cc_setFont:(UIFont *)font range:(NSRange)range;

- (void)cc_setColor:(UIColor *)color;
- (void)cc_setColor:(UIColor *)color range:(NSRange)range;

- (void)cc_setUnderlineColor:(UIColor *)color;
- (void)cc_setUnderlineColor:(UIColor *)color range:(NSRange)range;

- (void)cc_setUnderlineStyle:(NSUnderlineStyle)style;
- (void)cc_setUnderlineStyle:(NSUnderlineStyle)style range:(NSRange)range;

- (void)cc_setStrikethroughColor:(UIColor *)color;
- (void)cc_setStrikethroughColor:(UIColor *)color range:(NSRange)range;

- (void)cc_setStrikethroughStyle:(NSUnderlineStyle)style;
- (void)cc_setStrikethroughStyle:(NSUnderlineStyle)style range:(NSRange)range;

- (void)cc_setBgColor:(UIColor *)bgColor;
- (void)cc_setBgColor:(UIColor *)bgColor range:(NSRange)range;

- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor tapAction:(CCTapActionBlock)tapAction;
- (void)cc_setHighlightedColor:(UIColor *)color bgColor:(UIColor *)bgColor range:(NSRange)range tapAction:(CCTapActionBlock)tapAction;

/// default is 0, If supported by the specified font, a value of 1 enables superscripting and a value of -1 enables subscripting
- (void)cc_setSuperscript:(NSInteger)superScript;
- (void)cc_setSuperscript:(NSInteger)superScript range:(NSRange)range;

/// paragraphStyle
- (void)cc_setAlignment:(NSTextAlignment)alignment NS_AVAILABLE_IOS(6_0);
- (void)cc_setAlignment:(NSTextAlignment)alignment range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setFirstLineHeadIndent:(CGFloat)indent NS_AVAILABLE_IOS(6_0);
- (void)cc_setFirstLineHeadIndent:(CGFloat)indent range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setHeadIndent:(CGFloat)indent NS_AVAILABLE_IOS(6_0);
- (void)cc_setHeadIndent:(CGFloat)indent range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setTailIndent:(CGFloat)indent NS_AVAILABLE_IOS(6_0);
- (void)cc_setTailIndent:(CGFloat)indent range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setLineBreakModel:(NSLineBreakMode)mode NS_AVAILABLE_IOS(6_0);
- (void)cc_setLineBreakModel:(NSLineBreakMode)mode range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setLineSpacing:(CGFloat)spacing NS_AVAILABLE_IOS(6_0);
- (void)cc_setLineSpacing:(CGFloat)spacing range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setParagraphSpacing:(CGFloat)spacing NS_AVAILABLE_IOS(6_0);
- (void)cc_setParagraphSpacing:(CGFloat)spacing range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)cc_setParagraphSpacingBefore:(CGFloat)spacing NS_AVAILABLE_IOS(6_0);
- (void)cc_setParagraphSpacingBefore:(CGFloat)spacing range:(NSRange)range NS_AVAILABLE_IOS(6_0);

/// Core Text doesn't support automatic hyphenation, maybe you can use TextKit.
/// check `CTParagraphStyleSpecifier` for more infomation.
- (void)cc_setHyphenationFactor:(float)factor NS_AVAILABLE_IOS(6_0);
- (void)cc_setHyphenationFactor:(float)factor range:(NSRange)range NS_AVAILABLE_IOS(6_0);

/// attachment
- (void)cc_setAttachmentWithContent:(id)content
                        contentMode:(UIViewContentMode)contentMode
                        contentSize:(CGSize)contentSize alignToFont:(UIFont *)font
                 attachmentPosition:(CCTextAttachmentPosition)position range:(NSRange)range;
- (void)cc_setAttachmentStringWithContent:(id)content
                              contentMode:(UIViewContentMode)contentMode
                                    width:(CGFloat)width ascent:(CGFloat)ascent descent:(CGFloat)descent range:(NSRange)range;

@end
