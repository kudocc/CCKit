//
//  NSAttributedString+MDLUtil.h
//  CCKitDemo
//
//  Created by rui yuan on 2017/12/3.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (MDLUtil)

+ (instancetype)mdl_attributedStringWithString:(NSString *)string;
+ (instancetype)mdl_attributedStringWithString:(NSString *)string attributes:(NSDictionary<NSString *,id> *)attributes;

/// convenient methods to initialize NSAttributedString with textColor and font
+ (instancetype)mdl_attributedStringWithString:(NSString *)string textColor:(UIColor *)color;
+ (instancetype)mdl_attributedStringWithString:(NSString *)string font:(UIFont *)font;
+ (instancetype)mdl_attributedStringWithString:(NSString *)string textColor:(UIColor *)color font:(UIFont *)font;

+ (instancetype)mdl_attributedStringWithImage:(UIImage *)image bounds:(CGRect)bounds;

/// get the attributes of the first character
- (NSDictionary *)mdl_attributes;
- (NSDictionary *)mdl_attributesAtIndex:(NSUInteger)index;

/// get the font of the first character
- (UIFont *)mdl_font;
- (UIFont *)mdl_fontAtIndex:(NSUInteger)index;

/// get the color of the first character
- (UIColor *)mdl_color;
- (UIColor *)mdl_colorAtIndex:(NSUInteger)index;

/// get the underline color of the first character
- (UIColor *)mdl_underlineColor;
- (UIColor *)mdl_underlineColorAtIndex:(NSUInteger)index;

/// get the underline style of the first character
- (NSUnderlineStyle)mdl_underlineStyle;
- (NSUnderlineStyle)mdl_underlineStyleAtIndex:(NSUInteger)index;

/// get the strikethrough color of the first character
- (UIColor *)mdl_strikethroughColor;
- (UIColor *)mdl_strikethroughColorAtIndex:(NSUInteger)index;

/// get the strikethrough style of the first character
- (NSUnderlineStyle)mdl_strikethroughStyle;
- (NSUnderlineStyle)mdl_strikethroughStyleAtIndex:(NSUInteger)index;

/// get the background color of the first character
- (UIColor *)mdl_bgColor;
- (UIColor *)mdl_bgColorAtIndex:(NSUInteger)index;

/// get the NSParagrahStyle
- (NSParagraphStyle *)mdl_paragraphStyle;
- (NSParagraphStyle *)mdl_paragraphStyleAtIndex:(NSUInteger)index;

@end

@interface NSMutableAttributedString (MDLUtil)

/// call `mdl_addAttributes:overrideOldAttribute:` with overrideOld=YES.
- (void)mdl_addAttributes:(NSDictionary<NSString *, id> *)attributes;
/// call `mdl_addAttributes:range:overrideOldAttribute:` with range=NSMakeRange(0, self.length)
- (void)mdl_addAttributes:(NSDictionary<NSString *, id> *)attributes overrideOldAttribute:(BOOL)overrideOld;
/// for each attribute and value in attributes, call `addAttribute:value:range`, if overideOld is NO and there is a value at range.location, do nothing on that attribute.
- (void)mdl_addAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range overrideOldAttribute:(BOOL)overrideOld;

- (void)mdl_setAttributes:(NSDictionary<NSString *, id> *)attributes;
/// call `setAttributes:range:`
- (void)mdl_setAttributes:(NSDictionary<NSString *, id> *)attributes range:(NSRange)range;

- (void)mdl_setFont:(UIFont *)font;
- (void)mdl_setFont:(UIFont *)font range:(NSRange)range;

- (void)mdl_setColor:(UIColor *)color;
- (void)mdl_setColor:(UIColor *)color range:(NSRange)range;

- (void)mdl_setUnderlineColor:(UIColor *)color;
- (void)mdl_setUnderlineColor:(UIColor *)color range:(NSRange)range;

- (void)mdl_setUnderlineStyle:(NSUnderlineStyle)style;
- (void)mdl_setUnderlineStyle:(NSUnderlineStyle)style range:(NSRange)range;

- (void)mdl_setStrikethroughColor:(UIColor *)color;
- (void)mdl_setStrikethroughColor:(UIColor *)color range:(NSRange)range;

- (void)mdl_setStrikethroughStyle:(NSUnderlineStyle)style;
- (void)mdl_setStrikethroughStyle:(NSUnderlineStyle)style range:(NSRange)range;

- (void)mdl_setBgColor:(UIColor *)bgColor;
- (void)mdl_setBgColor:(UIColor *)bgColor range:(NSRange)range;

/// paragraphStyle
- (void)mdl_setAlignment:(NSTextAlignment)alignment NS_AVAILABLE_IOS(6_0);
- (void)mdl_setAlignment:(NSTextAlignment)alignment range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setFirstLineHeadIndent:(CGFloat)indent NS_AVAILABLE_IOS(6_0);
- (void)mdl_setFirstLineHeadIndent:(CGFloat)indent range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setHeadIndent:(CGFloat)indent NS_AVAILABLE_IOS(6_0);
- (void)mdl_setHeadIndent:(CGFloat)indent range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setTailIndent:(CGFloat)indent NS_AVAILABLE_IOS(6_0);
- (void)mdl_setTailIndent:(CGFloat)indent range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setLineBreakModel:(NSLineBreakMode)mode NS_AVAILABLE_IOS(6_0);
- (void)mdl_setLineBreakModel:(NSLineBreakMode)mode range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setLineSpacing:(CGFloat)spacing NS_AVAILABLE_IOS(6_0);
- (void)mdl_setLineSpacing:(CGFloat)spacing range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setParagraphSpacing:(CGFloat)spacing NS_AVAILABLE_IOS(6_0);
- (void)mdl_setParagraphSpacing:(CGFloat)spacing range:(NSRange)range NS_AVAILABLE_IOS(6_0);

- (void)mdl_setParagraphSpacingBefore:(CGFloat)spacing NS_AVAILABLE_IOS(6_0);
- (void)mdl_setParagraphSpacingBefore:(CGFloat)spacing range:(NSRange)range NS_AVAILABLE_IOS(6_0);

/// Core Text doesn't support automatic hyphenation, maybe you can use TextKit.
/// check `CTParagraphStyleSpecifier` for more infomation.
- (void)mdl_setHyphenationFactor:(float)factor NS_AVAILABLE_IOS(6_0);
- (void)mdl_setHyphenationFactor:(float)factor range:(NSRange)range NS_AVAILABLE_IOS(6_0);

@end
