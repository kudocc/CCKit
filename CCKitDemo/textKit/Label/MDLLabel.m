//
//  MDLLabel.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "MDLLabel.h"
#import "NSAttributedString+MDLUtil.h"

NSAttributedStringKey MDLHighlightAttributeName = @"MDLHighlightAttributeName";

@implementation MDLHighlightAttributeValue

- (id)copyWithZone:(nullable NSZone *)zone {
    MDLHighlightAttributeValue *copyValue = [[MDLHighlightAttributeValue alloc] init];
    copyValue.effectRange = self.effectRange;
    copyValue.highlightTextColor = self.highlightTextColor;
    copyValue.highlightBackgroundColor = self.highlightBackgroundColor;
    return copyValue;
}

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


@interface MDLTextAttachment ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CGSize size;

@end

@implementation MDLTextAttachment

+ (instancetype)imageAttachmentWithImage:(UIImage *)image size:(CGSize)size alignFont:(UIFont *)font {
    MDLTextAttachment *at = [[MDLTextAttachment alloc] initWithImage:image size:size alignFont:font];
    return at;
}

- (instancetype)initWithImage:(UIImage *)image size:(CGSize)size alignFont:(UIFont *)font {
    self = [super init];
    if (self) {
        self.size = size;
        if (image.images.count > 1) {
            // gif
            self.imageView = [[UIImageView alloc] initWithImage:image];
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        } else {
            self.image = image;
        }
        self.bounds = CGRectMake(0, font.descender, size.width, size.height);
    }
    return self;
}

@end


@interface MDLLabelLayoutManager : NSLayoutManager

@end


@interface MDLLabelLayout () <NSLayoutManagerDelegate>

@property (nonatomic) MDLLabelLayoutManager *layoutManager;
@property (nonatomic) NSTextContainer *textContainer;
@property (nonatomic) NSTextStorage *textStorage;

@end

@implementation MDLLabelLayout

+ (instancetype)labelLayoutWithAttributedText:(NSAttributedString *)text textContainer:(NSTextContainer *)textContainer {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:text];
    
    MDLLabelLayoutManager *layoutManager = [[MDLLabelLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    MDLLabelLayout *layout = [[MDLLabelLayout alloc] init];
    layout.layoutManager = layoutManager;
    layout.textContainer = textContainer;
    layout.textStorage = textStorage;
    layoutManager.delegate = layout;
    return layout;
}

+ (instancetype)labelLayoutWithAttributedText:(NSAttributedString *)text maxSize:(CGSize)size {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:text];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = 0;
    
    MDLLabelLayoutManager *layoutManager = [[MDLLabelLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    MDLLabelLayout *layout = [[MDLLabelLayout alloc] init];
    layout.layoutManager = layoutManager;
    layout.textContainer = textContainer;
    layout.textStorage = textStorage;
    layoutManager.delegate = layout;
    return layout;
}

- (CGSize)bounds {
    CGRect bounds = [self.layoutManager usedRectForTextContainer:self.textContainer];
    return CGSizeMake(self.textContainer.lineFragmentPadding * 2 + ceil(bounds.size.width), ceil(bounds.size.height));
}

#pragma mark - NSLayoutManagerDelegate

//- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex {
//    NSString *text = [layoutManager.textStorage attributedSubstringFromRange:NSMakeRange(charIndex, 1)].string;
//    static int i = 0;
//    ++i;
//    if (i%100 != 0) {
//        NSLog(@"%@ index %@, text %@, YES", NSStringFromSelector(_cmd), @(charIndex), text);
//        return YES;
//    } else {
//        NSLog(@"%@ index %@, text %@, NO", NSStringFromSelector(_cmd), @(charIndex), text);
//        return NO;
//    }
//}

//- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex {
//    NSString *text = [layoutManager.textStorage attributedSubstringFromRange:NSMakeRange(charIndex, 1)].string;
//    static int i = 0;
//    ++i;
//    if (i%100 != 0) {
//        NSLog(@"%@ index %@, text %@, YES", NSStringFromSelector(_cmd), @(charIndex), text);
//        return YES;
//    } else {
//        NSLog(@"%@ index %@, text %@, NO", NSStringFromSelector(_cmd), @(charIndex), text);
//        return NO;
//    }
//}

//- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager shouldUseAction:(NSControlCharacterAction)action forControlCharacterAtIndex:(NSUInteger)charIndex {
//    NSLog(@"%@, index:%@", NSStringFromSelector(_cmd), @(charIndex));
//    return NSControlCharacterActionZeroAdvancement;
//}

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    NSLog(@"%@, layoutFinishedFlag:%@", NSStringFromSelector(_cmd), @(layoutFinishedFlag));
}

@end

typedef void(^MDLDataDetectorCallback)(NSArray *matchResults);
@interface MDLDataDetectorOperation : NSOperation
@property (nonatomic) UIDataDetectorTypes types;
@property (nonatomic) NSString *string;
@property (nonatomic) MDLDataDetectorCallback callback;
@end

@implementation MDLDataDetectorOperation

- (NSArray<NSTextCheckingResult *> *)matchResultsInString:(NSString *)string withDataDetector:(UIDataDetectorTypes)types {
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:types error:nil];
    NSArray *matches = [detector matchesInString:string
                                         options:0
                                           range:NSMakeRange(0, [string length])];
    return matches;
}

- (void)main {
    NSAssert(self.string, @"should not be nil");
    NSAssert(self.callback, @"should not be nil");
    
    if (self.cancelled) {
        return;
    }
    NSArray *results = [self matchResultsInString:self.string withDataDetector:self.types];
    if (self.cancelled) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) {
            self.callback(results);
        }
    });
}

@end

const CGFloat MDLLabelMaxWidth = 9999;
const CGFloat MDLLabelMaxHeight = 9999;

@interface MDLLabel () <NSLayoutManagerDelegate> {
    NSRange _effectiveRangeTextHighlight;
    NSDictionary *_textHighlightedAttributeSaved;
    MDLHighlightAttributeValue *_highlightValue;
    
    NSTimer *_longPressTimer;
}

@property (nonatomic) NSMutableAttributedString *innerAttributedString;

// data detector
@property (nonatomic) BOOL needReDetectLink;
@property (nonatomic) int dataDetectorRefreshSessionID;
@property (nonatomic) NSArray<NSTextCheckingResult *> *dataDetectorMatchResults;
@property (nonatomic) NSOperationQueue *dataDetectQueue;

// layout
@property (nonatomic) BOOL needLayout;
@property (nonatomic) MDLLabelLayout *layout;

@end

@implementation MDLLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    // default value
    self.backgroundColor = [UIColor clearColor];
    
    _numberOfLines = 1;
    _font = [UIFont systemFontOfSize:17];
    _textColor = [UIColor blackColor];
    _textAlignment = NSTextAlignmentLeft;
    _lineBreakMode = NSLineBreakByWordWrapping;
    
    
    MDLHighlightAttributeValue *highlightValue = [MDLHighlightAttributeValue new];
    highlightValue.highlightTextColor = [UIColor blueColor];
    highlightValue.highlightBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blueColor],
                             MDLHighlightAttributeName : highlightValue,
                             };
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

- (MDLHighlightAttributeValue *)_getHighlightAttributeValueAtPosition:(CGPoint)pos exffectiveRange:(NSRange *)pRange {
    if (!_layout) {
        return nil;
    }
    NSLayoutManager *_layoutManager = _layout.layoutManager;
    NSTextContainer *_textContainer = _layout.textContainer;
    NSTextStorage *_textStorage = _layout.textStorage;
    
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:pos inTextContainer:_textContainer];
    NSUInteger characterIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    NSRange range;
    MDLHighlightAttributeValue *highlight = [_textStorage mdl_highlightAttributeValueAtIndex:characterIndex effectiveRange:&range];
    if (!highlight || range.location == NSNotFound || range.length == 0) {
        return nil;
    }
    if (pRange) {
        *pRange = range;
    }
    return highlight;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint pos = [[touches anyObject] locationInView:self];
    NSRange range;
    MDLHighlightAttributeValue *highlight = [self _getHighlightAttributeValueAtPosition:pos exffectiveRange:&range];
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
        
        NSLayoutManager *_layoutManager = _layout.layoutManager;
        NSTextContainer *_textContainer = _layout.textContainer;
        
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

- (void)_setNeedsLayout {
    self.needLayout = YES;
}

- (void)_setNeedRedraw {
    [self setNeedsDisplay];
}

- (void)_didModifyTextContent {
    [self invalidateIntrinsicContentSize];
    
    [self _setNeedsRefreshDataDetector];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)_didModifyTextAttribute {
    [self invalidateIntrinsicContentSize];
    
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

#pragma mark - Storage

- (void)setText:(NSString *)text {
    _text = text;
    
    _innerAttributedString = [[NSMutableAttributedString alloc] initWithString:_text];
    
    if (_font) {
        [_innerAttributedString mdl_setFont:_font];
    }
    if (_textColor) {
        [_innerAttributedString mdl_setColor:_textColor];
    }
    if (_shadowColor) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = _shadowColor;
        shadow.shadowOffset = _shadowOffset;
        [_innerAttributedString mdl_addAttributes:@{ NSShadowAttributeName : shadow }];
    }
    [_innerAttributedString mdl_setAlignment:_textAlignment];
    [_innerAttributedString mdl_setLineBreakModel:_lineBreakMode];
    
    [self _didModifyTextAttribute];
    [self _didModifyTextContent];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    if (_innerAttributedString) {
        [_innerAttributedString mdl_setFont:font];
    }
    
    [self _didModifyTextAttribute];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    if (_innerAttributedString) {
        [_innerAttributedString mdl_setColor:textColor];
    }
    
    [self _didModifyTextAttribute];
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
        [_innerAttributedString mdl_addAttributes:@{ NSShadowAttributeName : shadow }];
    }
    
    [self _didModifyTextAttribute];
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
        [_innerAttributedString mdl_addAttributes:@{ NSShadowAttributeName : shadow }];
    }
    
    [self _didModifyTextAttribute];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    
    if (_innerAttributedString) {
        [_innerAttributedString mdl_setAlignment:textAlignment];
    }
    
    [self _didModifyTextAttribute];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    
    if (_innerAttributedString) {
        [_innerAttributedString mdl_setLineBreakModel:lineBreakMode];
    }
    
    [self _didModifyTextAttribute];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _innerAttributedString = [attributedText mutableCopy];
    
    _text = [_innerAttributedString string];
    _textColor = [_innerAttributedString mdl_color];
    _font = [_innerAttributedString mdl_font];
    
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
    
    [self _didModifyTextAttribute];
    [self _didModifyTextContent];
}

#pragma mark - data detect

- (NSOperationQueue *)dataDetectQueue {
    if (!_dataDetectQueue) {
        _dataDetectQueue = [[NSOperationQueue alloc] init];
        _dataDetectQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return _dataDetectQueue;
}

- (void)_setNeedsRefreshDataDetector {
    // clear results because they maybe not valid any more
    self.dataDetectorMatchResults = nil;
    self.needReDetectLink = YES;
    ++self.dataDetectorRefreshSessionID;
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes {
    _dataDetectorTypes = dataDetectorTypes;
    
    [self _setNeedsRefreshDataDetector];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setLinkTextAttributes:(NSDictionary<NSString *,id> *)linkTextAttributes {
    _linkTextAttributes = [linkTextAttributes copy];
    
    [self _setNeedsRefreshDataDetector];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setAsyncDataDetector:(BOOL)asyncDataDetector {
    _asyncDataDetector = asyncDataDetector;
}

- (NSArray<NSTextCheckingResult *> *)matchResultsInString:(NSString *)string withDataDetector:(UIDataDetectorTypes)types {
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:types error:nil];
    NSArray *matches = [detector matchesInString:string
                                         options:0
                                           range:NSMakeRange(0, [string length])];
    return matches;
}

#pragma mark - layout & draw

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

// If you don't use autolayout (set frame explicitly), `intrinsicContentSize` won't be called.
- (CGSize)intrinsicContentSize {
    CGSize size = CGSizeZero;
    NSAttributedString *attr = _innerAttributedString;
    if (self.numberOfLines != 1) {
        if (self.preferredMaxLayoutWidth <= 0) {
            size = CGSizeMake(MDLLabelMaxWidth, MDLLabelMaxHeight);
        } else {
            size = CGSizeMake(self.preferredMaxLayoutWidth, MDLLabelMaxHeight);
        }
    } else {
        size = CGSizeMake(MDLLabelMaxWidth, MDLLabelMaxHeight);
    }
    
    NSTextContainer *_textContainer = [[NSTextContainer alloc] initWithSize:size];
    _textContainer.lineFragmentPadding = 0;
    _textContainer.maximumNumberOfLines = self.numberOfLines;
    
    MDLLabelLayout *layout = [MDLLabelLayout labelLayoutWithAttributedText:attr textContainer:_textContainer];
    return layout.bounds;
}

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    
    if (_needReDetectLink) {
        _dataDetectorMatchResults = nil;
        if (_dataDetectorTypes == UIDataDetectorTypeNone) {
            _needReDetectLink = NO;
        } else {
            if (_asyncDataDetector) {
                __weak typeof(self) wself = self;
                int sessionID = self.dataDetectorRefreshSessionID;
                MDLDataDetectorOperation *operation = [[MDLDataDetectorOperation alloc] init];
                operation.string = self.text;
                operation.types = self.dataDetectorTypes;
                operation.callback = ^(NSArray *matchResults) {
                    if (!wself || wself.dataDetectorRefreshSessionID != sessionID) {
#ifdef DEBUG
                        if (wself.dataDetectorRefreshSessionID != sessionID) {
                            NSLog(@"data detector refresh session id is not equal, maybe you have modify the text again");
                        }
#endif
                        return;
                    }
                    typeof(wself) sself = wself;
                    sself.dataDetectorMatchResults = matchResults;
                    [sself _setNeedsLayout];
                    [sself _setNeedRedraw];
                };
                [self.dataDetectQueue cancelAllOperations];
                [self.dataDetectQueue addOperation:operation];
                
                _needReDetectLink = NO;
            } else {
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:_dataDetectorTypes error:nil];
                NSString *string = [_innerAttributedString string];
                NSArray *matches = [detector matchesInString:string
                                                     options:0
                                                       range:NSMakeRange(0, [string length])];
                _dataDetectorMatchResults = [matches copy];
                _needReDetectLink = NO;
            }
        }
    }
    
    if (_needLayout) {
        _needLayout = NO;
        
        NSMutableAttributedString *mutableAttributedText = _innerAttributedString;
        if (self.dataDetectorMatchResults &&
            self.dataDetectorTypes != UIDataDetectorTypeNone &&
            self.linkTextAttributes) {
            for (NSTextCheckingResult *match in self.dataDetectorMatchResults) {
                NSRange matchRange = [match range];
                NSMutableDictionary *linkAttr = [self.linkTextAttributes mutableCopy];
                [self.linkTextAttributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([key isEqualToString:MDLHighlightAttributeName]) {
                        MDLHighlightAttributeValue *value = [obj copy];
                        value.effectRange = matchRange;
                        [linkAttr setObject:value forKey:key];
                    } else {
                        [linkAttr setObject:obj forKey:key];
                    }
                }];
                [mutableAttributedText mdl_addAttributes:linkAttr
                                                   range:matchRange
                                    overrideOldAttribute:YES];
            }
        }
        
        NSTextContainer *_textContainer = [[NSTextContainer alloc] initWithSize:size];
        _textContainer.lineFragmentPadding = 0;
        _textContainer.maximumNumberOfLines = self.numberOfLines;
        
        _layout = [MDLLabelLayout labelLayoutWithAttributedText:mutableAttributedText textContainer:_textContainer];
    }
    
    NSRange range = [_layout.layoutManager glyphRangeForTextContainer:_layout.textContainer];
    NSLog(@"%@, range:%@, bounds:%@", NSStringFromSelector(_cmd), NSStringFromRange(range), NSStringFromCGRect(rect));
    
    CGPoint pos = CGPointMake(0, 0);
    [_layout.layoutManager drawBackgroundForGlyphRange:range atPoint:pos];
    [_layout.layoutManager drawGlyphsForGlyphRange:range atPoint:pos];
    
    // place text attatchment
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    NSTextStorage *_textStorage = _layout.textStorage;
    [_textStorage enumerateAttribute:NSAttachmentAttributeName
                            inRange:NSMakeRange(0, _textStorage.length)
                            options:0
                         usingBlock:^(id value, NSRange range, BOOL *stop) {
                             if (![value isKindOfClass:[MDLTextAttachment class]]) {
                                 return;
                             }
                             MDLTextAttachment* attachment = (MDLTextAttachment*)value;
                             if (attachment.imageView) {
                                 NSRange glyphRange = [_layout.layoutManager glyphRangeForCharacterRange:range
                                                                                    actualCharacterRange:NULL];
                                 CGRect frame = [_layout.layoutManager boundingRectForGlyphRange:glyphRange
                                                                                 inTextContainer:_layout.textContainer];
                                 attachment.imageView.frame = frame;
                                 [self addSubview:attachment.imageView];
                                 [attachment.imageView startAnimating];
                             }
                         }];
}

- (NSTextCheckingTypes)dataDetectorTypesToTextCheckingTypes:(UIDataDetectorTypes)dataDetectorTypes {
    NSTextCheckingTypes result = 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypePhoneNumber) > 0) ? NSTextCheckingTypePhoneNumber : 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypeLink) > 0) ? NSTextCheckingTypeLink : 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypeAddress) > 0) ? NSTextCheckingTypeAddress : 0;
    result |= ((dataDetectorTypes & UIDataDetectorTypeCalendarEvent) > 0) ? NSTextCheckingTypeDate : 0;
    return result;
}

@end





@interface MDLLabelLayoutManager ()
@end

@implementation MDLLabelLayoutManager

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color {
    // Fill used rect only
    
    NSRange glyphRange = [self glyphRangeForCharacterRange:charRange actualCharacterRange:NULL];
    __block NSUInteger rectIndex = 0;
    NSMutableArray *mutableRects = [NSMutableArray array];
    [self enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        
        if (rectIndex >= rectCount) {
            NSAssert(NO, @"Amazing order to enumerate line fragment");
            *stop = YES;
            return;
        }
        
        CGRect rectOri = rectArray[rectIndex];
        CGRect rectResult = CGRectIntersection(rectOri, usedRect);
        if (!CGRectEqualToRect(rectResult, CGRectZero)) {
            [mutableRects addObject:[NSValue valueWithCGRect:rectResult]];
        }
        ++rectIndex;
    }];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    for (NSValue *valueRect in mutableRects) {
        CGContextFillRect(ctx, [valueRect CGRectValue]);
    }
    CGContextRestoreGState(ctx);
}

@end

