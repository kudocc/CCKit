//
//  MDLLabel.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "MDLLabel.h"
#import "NSAttributedString+CCKit.h"

NSAttributedStringKey MDLHighlightAttributeName = @"MDLHighlightAttributeName";

@implementation MDLHighlightAttributeValue

- (NSUInteger)hash {
    return self.effectRange.location;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MDLHighlightAttributeValue class]]) {
        return NO;
    }
    MDLHighlightAttributeValue *value = object;
    return NSEqualRanges(self.effectRange, value.effectRange);
}

- (NSDictionary *)attributes {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    if (_highlightBackgroundColor) {
        mutableDictionary[NSBackgroundColorAttributeName] = _highlightBackgroundColor;
    }
    if (_highlightTextColor) {
        mutableDictionary[NSForegroundColorAttributeName] = _highlightTextColor;
    }
    return [mutableDictionary copy];
}

@end

@implementation NSMutableAttributedString (MDLHighlightAttribute)

- (void)mdl_addHighlightAttributeValue:(MDLHighlightAttributeValue *)value range:(NSRange)range {
    [self addAttribute:MDLHighlightAttributeName value:value range:range];
}

- (void)mdl_removeHighlightAttributeValueRange:(NSRange)range {
    [self removeAttribute:MDLHighlightAttributeName range:range];
}

@end


@implementation NSAttributedString (MDLHighlightAttribute)

- (MDLHighlightAttributeValue *)mdl_highlightAttributeValueAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)range {
    return [self attribute:MDLHighlightAttributeName atIndex:index effectiveRange:range];
}

@end


@interface MDLLabelLayoutManager : NSLayoutManager

@end



typedef NS_OPTIONS(NSUInteger, MDLLabelLayoutFlag) {
    MDLLabelLayoutFlagRefreshDataDetector = 1 << 0,
    MDLLabelLayoutFlagLayout = 1 << 1,
};

NSString *const MDLLabelHighlightedTextAttribute = @"MDLLabelHighlightedTextAttribute";
NSString *const MDLLabelLinkTextAttribute = @"MDLLabelLinkTextAttribute";

const CGFloat MDLLabelMaxWidth = 9999;
const CGFloat MDLLabelMaxHeight = 9999;

@interface MDLLabel () <NSLayoutManagerDelegate> {
    NSRange _effectiveRangeTextHighlight;
    NSDictionary *_textHighlightedAttributeSaved;
    MDLHighlightAttributeValue *_highlightValue;
    
    NSTimer *_longPressTimer;
}

@property (nonatomic) MDLLabelLayoutFlag flag;

@property (nonatomic) BOOL needLayout;
@property (nonatomic) BOOL needRedraw;

@property (nonatomic) NSMutableAttributedString *innerAttributedString;

@property (nonatomic) NSTextStorage *textStorage;
@property (nonatomic) MDLLabelLayoutManager *layoutManager;
@property (nonatomic) NSTextContainer *textContainer;

@end

@implementation MDLLabel

- (instancetype)init {
    self = [super init];
    if (self) {
        // default value
        self.backgroundColor = [UIColor clearColor];
        
        _numberOfLines = 1;
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _textAlignment = NSTextAlignmentLeft;
        _lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

#pragma mark - Touch

- (void)startLongPressTimer {
    _longPressTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(longPressTimerFired:) userInfo:nil repeats:NO];
}

- (void)longPressTimerFired:(NSTimer *)t {
    if (_delegate && [_delegate respondsToSelector:@selector(label:didLongPressHighlight:inRange:)] && _highlightValue) {
        BOOL allow = YES;
        if ([_delegate respondsToSelector:@selector(label:shouldLongPressHighlight:inRange:)]) {
            allow = [_delegate label:self
            shouldLongPressHighlight:_highlightValue
                             inRange:_effectiveRangeTextHighlight];
        }
        if (allow) {
            [_delegate label:self didLongPressHighlight:_highlightValue inRange:_effectiveRangeTextHighlight];
        }
    }
    
    _longPressTimer = nil;
}

- (void)stopLongPressTimer {
    if ([_longPressTimer isValid]) {
        [_longPressTimer invalidate];
    }
    _longPressTimer = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    
    if (!_layoutManager || !_textContainer) {
        return;
    }
    
    CGPoint pos = [[touches anyObject] locationInView:self];
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:pos inTextContainer:_textContainer];
    NSUInteger characterIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    NSRange range;
    MDLHighlightAttributeValue *highlight = [_textStorage mdl_highlightAttributeValueAtIndex:characterIndex effectiveRange:&range];
    if (!highlight || range.location == NSNotFound || range.length == 0) {
        return;
    }
    
    [self startLongPressTimer];
    
    _highlightValue = highlight;
    _effectiveRangeTextHighlight = range;
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [_innerAttributedString enumerateAttributesInRange:_effectiveRangeTextHighlight options:0 usingBlock:^(NSDictionary<NSString *,id> *attrs, NSRange range, BOOL *stop) {
        NSValue *valueRange = [NSValue valueWithRange:range];
        mutableDict[valueRange] = attrs;
    }];
    _textHighlightedAttributeSaved = [mutableDict copy];
    [highlight.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [_innerAttributedString addAttribute:key value:obj range:_effectiveRangeTextHighlight];
    }];
    
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self stopLongPressTimer];
    
    if (_textHighlightedAttributeSaved) {
        [_textHighlightedAttributeSaved enumerateKeysAndObjectsUsingBlock:^(NSValue *key, id obj, BOOL * _Nonnull stop) {
            NSRange range = [key rangeValue];
            [_innerAttributedString setAttributes:obj range:range];
        }];
        [self _setNeedsLayout];
        [self _setNeedRedraw];
        
        BOOL touchUpInside = NO;
        CGPoint pos = [[touches anyObject] locationInView:self];
        NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:pos inTextContainer:_textContainer];
        NSUInteger characterIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        if (characterIndex >= _effectiveRangeTextHighlight.location &&
            characterIndex < _effectiveRangeTextHighlight.location + _effectiveRangeTextHighlight.length) {
            touchUpInside = YES;
        }
        if (touchUpInside) {
            if (_delegate && [_delegate respondsToSelector:@selector(label:didTapHighlight:inRange:)]) {
                BOOL allow = YES;
                if ([_delegate respondsToSelector:@selector(label:shouldTapHighlight:inRange:)]) {
                    allow = [_delegate label:self shouldTapHighlight:_highlightValue inRange:_effectiveRangeTextHighlight];
                }
                if (allow) {
                    [_delegate label:self didTapHighlight:_highlightValue inRange:_effectiveRangeTextHighlight];
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self stopLongPressTimer];
    
    if (_textHighlightedAttributeSaved) {
        [_textHighlightedAttributeSaved enumerateKeysAndObjectsUsingBlock:^(NSValue *key, id obj, BOOL * _Nonnull stop) {
            NSRange range = [key rangeValue];
            [_innerAttributedString setAttributes:obj range:range];
        }];
        [self _setNeedsLayout];
        [self _setNeedRedraw];
    }
}

#pragma mark - Property

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    [self invalidateIntrinsicContentSize];
}

- (void)_setNeedsRefreshDataDetector {
    self.flag |= MDLLabelLayoutFlagRefreshDataDetector;
}

- (void)_setNeedsLayout {
    self.needLayout = YES;
}

- (void)_setNeedRedraw {
    [self setNeedsDisplay];
}

- (void)_didModifyAttributedText {
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Storage

- (void)setText:(NSString *)text {
    _text = text;
    
    _innerAttributedString = [[NSMutableAttributedString alloc] initWithString:_text];
    if (_font) {
        [_innerAttributedString cc_setFont:_font];
    }
    
    if (_textColor) {
        [_innerAttributedString cc_setColor:_textColor];
    }
    
    [_innerAttributedString cc_setAlignment:_textAlignment];
    
    [_innerAttributedString cc_setLineBreakModel:_lineBreakMode];
    
    [self _didModifyAttributedText];
    [self _setNeedsRefreshDataDetector];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    if (_innerAttributedString) {
        [_innerAttributedString cc_setFont:font];
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    if (_innerAttributedString) {
        [_innerAttributedString cc_setColor:textColor];
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    
    if (_innerAttributedString) {
        NSMutableDictionary *attr = [[_innerAttributedString attributesAtIndex:0 effectiveRange:NULL] copy];
        NSShadow *shadow = attr[NSShadowAttributeName];
        if (!shadow) {
            shadow = [[NSShadow alloc] init];
        }
        shadow.shadowColor = shadowColor;
        [_innerAttributedString cc_addAttributes:@{ NSShadowAttributeName : shadow }];
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    
    if (_innerAttributedString) {
        NSDictionary *attr = [_innerAttributedString attributesAtIndex:0 effectiveRange:NULL];
        NSShadow *shadow = attr[NSShadowAttributeName];
        if (!shadow) {
            shadow = [[NSShadow alloc] init];
        }
        shadow.shadowOffset = shadowOffset;
        [_innerAttributedString cc_addAttributes:@{ NSShadowAttributeName : shadow }];
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    
    if (_innerAttributedString) {
        [_innerAttributedString cc_setAlignment:textAlignment];
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    
    if (_innerAttributedString) {
        [_innerAttributedString cc_setLineBreakModel:lineBreakMode];
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes {
    _dataDetectorTypes = dataDetectorTypes;
    
    [self _setNeedsRefreshDataDetector];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _innerAttributedString = [attributedText mutableCopy];
    
    _textColor = [_innerAttributedString cc_color];
    _font = [_innerAttributedString cc_font];
    
    NSDictionary *attr = [_innerAttributedString attributesAtIndex:0 effectiveRange:NULL];
    NSParagraphStyle *paragraph = attr[NSParagraphStyleAttributeName];
    if (paragraph) {
        _textAlignment = paragraph.alignment;
        _lineBreakMode = paragraph.lineBreakMode;
    }
    
    
    NSShadow *shadow = attr[NSShadowAttributeName];
    if (shadow) {
        _shadowOffset = shadow.shadowOffset;
        _shadowColor = shadow.shadowColor;
    }
    
    [self _didModifyAttributedText];
    [self _setNeedsRefreshDataDetector];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

/*
 if (self.dataDetectorTypes == 0) {
 NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:self.dataDetectorTypes error:nil];
 NSString *string = [_innerAttributedString string];
 NSArray *matches = [detector matchesInString:string
 options:0
 range:NSMakeRange(0, [string length])];
 for (NSTextCheckingResult *match in matches) {
 NSRange matchRange = [match range];
 if (self.highlightTextAttributes) {
 [_innerAttributedString cc_addAttributes:@{MDLLabelHighlightedTextAttribute:self.highlightTextAttributes} range:matchRange overrideOldAttribute:YES];
 }
 if (self.linkTextAttributes) {
 [_innerAttributedString cc_addAttributes:self.linkTextAttributes range:matchRange overrideOldAttribute:YES];
 }
 }
 }*/

- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeZero;
    NSAttributedString *attr = _innerAttributedString;
    if (self.numberOfLines != 1) {
        if (self.preferredMaxLayoutWidth == 0) {
            size = CGSizeMake(MDLLabelMaxWidth, MDLLabelMaxHeight);
        } else {
            size = CGSizeMake(self.preferredMaxLayoutWidth, MDLLabelMaxHeight);
        }
    } else {
        size = CGSizeMake(MDLLabelMaxWidth, MDLLabelMaxHeight);
//        NSRange range = {NSNotFound, 0};
//        NSString *string = _innerAttributedString.string;
//        range = [string rangeOfString:@"\n"];
//        if (range.location == NSNotFound) {
//            range = [string rangeOfString:@"\r"];
//        }
//        if (range.location != NSNotFound) {
//            attr = [_innerAttributedString attributedSubstringFromRange:NSMakeRange(0, range.location)];
//        }
    }
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attr];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    
    MDLLabelLayoutManager *layoutManager = [[MDLLabelLayoutManager alloc] init];
    [layoutManager setDelegate:self];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    CGFloat width = 0;
    CGFloat height = 0;
    NSInteger indexWidth = 0;
    NSString *str;
    
    CGRect bounds = [layoutManager usedRectForTextContainer:textContainer];
    NSRange range = [layoutManager glyphRangeForTextContainer:textContainer];
    for (NSInteger i = range.location; i < range.location + range.length; ++i) {
        CGRect rect = [layoutManager boundingRectForGlyphRange:NSMakeRange(range.location+i, 1)
                                                inTextContainer:textContainer];
        
        NSInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:range.location+i];
        NSString *sub = [layoutManager.textStorage.string substringWithRange:NSMakeRange(charIndex, 1)];
        
        if (width < CGRectGetMaxX(rect)) {
            width = CGRectGetMaxX(rect);
            indexWidth = charIndex;
            str = [sub copy];
        }
        height = height < CGRectGetMaxY(rect) ? CGRectGetMaxY(rect) : height;
        NSLog(@"sub %@, %@, %@", NSStringFromCGRect(rect), @(charIndex), sub);
    }
    
    NSLog(@"max x, y, %@, %@, sub:%@, index:%@", @(width), @(height), str, @(indexWidth));
    
//    NSUInteger last = range.length > 0 ? (range.location + range.length - 1) : NSNotFound;
//    if (last != NSNotFound) {
//        NSRange range;
//        [layoutManager lineFragmentRectForGlyphAtIndex:last effectiveRange:&range];
//        NSRange characterRange = [layoutManager characterRangeForGlyphRange:range actualGlyphRange:NULL];
//        CGSize
//        [layoutManager.textStorage enumerateAttribute:NSShadowAttributeName inRange:characterRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//            NSDictionary *attr = [layoutManager.textStorage attributesAtIndex:range.location effectiveRange:NULL];
//            NSShadow *shadow = attr[NSShadowAttributeName];
//        }];
//    }
    
    NSLog(@"%@, range:%@, bounds:%@", NSStringFromSelector(_cmd), NSStringFromRange(range), NSStringFromCGRect(bounds));
    return CGSizeMake(textContainer.lineFragmentPadding * 2 + ceil(bounds.size.width), ceil(bounds.size.height));
}

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    if (_needLayout) {
        _needLayout = NO;
        
        NSAttributedString *attr = _innerAttributedString;
        /*
        if (self.numberOfLines == 1) {
            NSRange range = {NSNotFound, 0};
            NSString *string = _innerAttributedString.string;
            range = [string rangeOfString:@"\n"];
            if (range.location == NSNotFound) {
                range = [string rangeOfString:@"\r"];
            }
            if (range.location != NSNotFound) {
                attr = [_innerAttributedString attributedSubstringFromRange:NSMakeRange(0, range.location)];
            }
        }*/
        
        _textStorage = [[NSTextStorage alloc] initWithAttributedString:_innerAttributedString];
        
        _textContainer = [[NSTextContainer alloc] initWithSize:size];
        _textContainer.lineFragmentPadding = 0;
        _textContainer.maximumNumberOfLines = self.numberOfLines;
        
        _layoutManager = [[MDLLabelLayoutManager alloc] init];
        [_layoutManager setDelegate:self];
        [_layoutManager addTextContainer:_textContainer];
        [_layoutManager setTextStorage:_textStorage];
        
        NSRange range = [_layoutManager glyphRangeForTextContainer:_textContainer];
        [_layoutManager boundingRectForGlyphRange:range inTextContainer:_textContainer];
    }
    
    NSRange range = [_layoutManager glyphRangeForTextContainer:_textContainer];
    NSLog(@"%@, range:%@, bounds:%@", NSStringFromSelector(_cmd), NSStringFromRange(range), NSStringFromCGRect(rect));
    
    // Didn't take `NSBackgroundColorAttributeName` into consideration
    CGPoint pos = CGPointMake(0, 0);
    [_layoutManager drawBackgroundForGlyphRange:range atPoint:pos];
    [_layoutManager drawGlyphsForGlyphRange:range atPoint:pos];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(ctx, 1);
    for (NSInteger i = range.location; i < range.location + range.length; ++i) {
        CGRect rect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(range.location+i, 1)
                                                inTextContainer:_textContainer];
        NSInteger charIndex = [_layoutManager characterIndexForGlyphAtIndex:range.location+i];
        NSString *sub = [_layoutManager.textStorage.string substringWithRange:NSMakeRange(charIndex, 1)];
        NSLog(@"sub %@, %@, %@", NSStringFromCGRect(rect), @(charIndex), sub);
        CGContextStrokeRect(ctx, rect);
    }
}

- (NSTextCheckingTypes)dataDetectorTypesToTextCheckingTypes:(UIDataDetectorTypes)dataDetectorTypes {
    NSTextCheckingTypes result = 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypePhoneNumber) > 0) ? NSTextCheckingTypePhoneNumber : 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypeLink) > 0) ? NSTextCheckingTypeLink : 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypeAddress) > 0) ? NSTextCheckingTypeAddress : 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypeCalendarEvent) > 0) ? NSTextCheckingTypeDate : 0;
    return result;
}

#pragma mark - NSLayoutManagerDelegate

//- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager shouldUseAction:(NSControlCharacterAction)action forControlCharacterAtIndex:(NSUInteger)charIndex {
//    NSLog(@"%@, index:%@", NSStringFromSelector(_cmd), @(charIndex));
//    return NSControlCharacterActionZeroAdvancement;
//}

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    NSLog(@"%@, layoutFinishedFlag:%@", NSStringFromSelector(_cmd), @(layoutFinishedFlag));
}

@end





@interface MDLLabelLayoutManager ()
@end

@implementation MDLLabelLayoutManager

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color {
    NSDictionary *attr = [self.textStorage attributesAtIndex:charRange.location effectiveRange:NULL];
    NSParagraphStyle *paragraph = attr[NSParagraphStyleAttributeName];
    CGFloat lineSpacing = 0;
    if (paragraph) {
        lineSpacing = paragraph.lineSpacing;
    }
//    NSLog(@"range %@", NSStringFromRange(charRange));
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (NSUInteger i = 0; i < rectCount; ++i) {
//        NSLog(@"fill rect %@", NSStringFromCGRect(*(rectArray+i)));
        
        CGRect rect = *(rectArray+i);
        rect.size.height -= lineSpacing;
        CGContextFillRect(ctx, rect);
    }
    
}

@end

