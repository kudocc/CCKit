//
//  MDLLabel.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "MDLLabel.h"
#import "NSAttributedString+MDLUtil.h"

NSString *MDLHighlightAttributeName = @"MDLHighlightAttributeName";

/**
 Get the `AppleColorEmoji` font's ascent with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font ascent.
 */
static inline CGFloat MDLTextEmojiGetAscentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 1.25 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        return 0.5 * fontSize + 12;
    } else {
        return fontSize;
    }
}

/**
 Get the `AppleColorEmoji` font's descent with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font descent.
 */
static inline CGFloat MDLTextEmojiGetDescentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 0.390625 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        return 0.15625 * fontSize + 3.75;
    } else {
        return 0.3125 * fontSize;
    }
    return 0;
}

/**
 Get the `AppleColorEmoji` font's glyph bounding rect with a specified font size.
 It may used to create custom emoji.
 
 @param fontSize  The specified font size.
 @return The font glyph bounding rect.
 */
static inline CGRect MDLTextEmojiGetGlyphBoundingRectWithFontSize(CGFloat fontSize) {
    CGRect rect;
    rect.origin.x = 0.75;
    rect.size.width = rect.size.height = MDLTextEmojiGetAscentWithFontSize(fontSize);
    if (fontSize < 16) {
        rect.origin.y = -0.2525 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        rect.origin.y = 0.1225 * fontSize -6;
    } else {
        rect.origin.y = -0.1275 * fontSize;
    }
    return rect;
}

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


@implementation NSAttributedString (MDLTextAttachment)
+ (NSAttributedString *)mdl_attachmentStringWithEmojiImage:(UIImage *)image fontSize:(CGFloat)fontSize {
    CGFloat ascent = MDLTextEmojiGetAscentWithFontSize(fontSize);
    CGFloat descent = MDLTextEmojiGetDescentWithFontSize(fontSize);
    CGRect bounding = MDLTextEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    
    CGRect bounds = CGRectMake(0, -descent, bounding.size.width + 2 * bounding.origin.x, bounding.size.height);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), bounding.origin.x, descent + bounding.origin.y, bounding.origin.x);
    MDLTextAttachment *textAttachment = [MDLTextAttachment imageAttachmentWithImage:image bounds:bounds contentInsets:contentInsets];
    NSAttributedString *attr = [NSAttributedString attributedStringWithAttachment:textAttachment];
    return attr;
}
@end


@interface MDLTextAttachment ()

// for GIF image
@property (nonatomic) UIImageView *imageView;

// for non-animate image but has non-zero contentInsets, we must draw byourselves
@property (nonatomic) UIImage *customImage;

@property (nonatomic) UIEdgeInsets contentInsets;

@end

@implementation MDLTextAttachment

+ (instancetype)imageAttachmentWithImage:(UIImage *)image size:(CGSize)size alignFont:(UIFont *)font {
    CGRect bounds = CGRectMake(0, font.descender, size.width, size.height);
    return [MDLTextAttachment imageAttachmentWithImage:image bounds:bounds contentInsets:UIEdgeInsetsZero];
}

+ (instancetype)imageAttachmentWithImage:(UIImage *)image bounds:(CGRect)bounds contentInsets:(UIEdgeInsets)contentInsets {
    MDLTextAttachment *at = [[MDLTextAttachment alloc] initWithImage:image bounds:bounds contentInsets:contentInsets];
    return at;
}

- (instancetype)initWithImage:(UIImage *)image bounds:(CGRect)bounds contentInsets:(UIEdgeInsets)contentInsets {
    self = [super init];
    if (self) {
        if (image.images.count > 1) {
            self.imageView = [[UIImageView alloc] initWithImage:image];
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            CGRect frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, bounds.size.width, bounds.size.height), contentInsets);
            self.imageView.frame = frame;
        } else if (UIEdgeInsetsEqualToEdgeInsets(contentInsets, UIEdgeInsetsZero)) {
            self.image = image;
        } else {
            self.customImage = image;
        }
        self.bounds = bounds;
    }
    return self;
}

@end


@interface MDLLabelLayoutManager : NSLayoutManager

@property (nonatomic) CGPoint  drawPosition;

@end


@interface MDLLabelLayout () <NSLayoutManagerDelegate>

@property (nonatomic) MDLLabelLayoutManager *layoutManager;
@property (nonatomic) NSTextContainer *textContainer;
@property (nonatomic) NSTextStorage *textStorage;
@property (nonatomic) CGPoint drawPosition;

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

- (CGPoint)layoutPositionFromLabelPosition:(CGPoint)pos {
    return CGPointMake(pos.x - _layoutManager.drawPosition.x, pos.y - _layoutManager.drawPosition.y);
}

- (void)setDrawPosition:(CGPoint)drawPosition {
    _layoutManager.drawPosition = drawPosition;
}

- (CGSize)bounds {
    CGRect bounds = [self.layoutManager usedRectForTextContainer:self.textContainer];
    return CGSizeMake(self.textContainer.lineFragmentPadding * 2 + ceil(bounds.size.width), ceil(bounds.size.height));
}

#pragma mark - NSLayoutManagerDelegate

#ifdef DEBUG
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    NSLog(@"%@, layoutFinishedFlag:%@", NSStringFromSelector(_cmd), @(layoutFinishedFlag));
}
#endif

@end

typedef void(^MDLDataDetectorCallback)(NSArray *matchResults);
@interface MDLDataDetectorOperation : NSOperation
@property (nonatomic) UIDataDetectorTypes types;
@property (nonatomic) NSString *string;
@property (nonatomic) NSDataDetector *customDetector;
@property (nonatomic) MDLDataDetectorCallback callback;
@end

@implementation MDLDataDetectorOperation

- (NSArray<NSTextCheckingResult *> *)matchResultsInString:(NSString *)string withDataDetector:(UIDataDetectorTypes)types {
    NSDataDetector *detector = self.customDetector ?: [NSDataDetector dataDetectorWithTypes:types error:nil];
    NSMutableArray<NSTextCheckingResult *> *matches = [NSMutableArray array];
    [detector enumerateMatchesInString:string options:kNilOptions range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [matches addObject:result];
    }];
    return [matches copy];
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
    highlightValue.highlightBackgroundColor = [UIColor colorWithWhite:0.1 alpha:0.2];
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
    pos = [_layout layoutPositionFromLabelPosition:pos];
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
    NSDataDetector *detector = self.customDataDetector ?: [NSDataDetector dataDetectorWithTypes:types error:nil];
    NSMutableArray<NSTextCheckingResult *> *matches = [NSMutableArray array];
    [detector enumerateMatchesInString:string options:kNilOptions range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [matches addObject:result];
    }];
    return [matches copy];
}

#pragma mark - layout & draw

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    _textContainerInset = textContainerInset;
    
    [self invalidateIntrinsicContentSize];
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self _setNeedsLayout];
    [self _setNeedRedraw];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = CGSizeMake(size.width, MDLLabelMaxHeight);
    NSAttributedString *attr = _innerAttributedString;
    NSTextContainer *_textContainer = [[NSTextContainer alloc] initWithSize:size];
    _textContainer.lineFragmentPadding = 0;
    _textContainer.maximumNumberOfLines = self.numberOfLines;
    
    MDLLabelLayout *layout = [MDLLabelLayout labelLayoutWithAttributedText:attr textContainer:_textContainer];
    CGSize layoutBounds = layout.bounds;
    return CGSizeMake(layoutBounds.width + self.textContainerInset.left + self.textContainerInset.right,
                      layoutBounds.height + self.textContainerInset.top + self.textContainerInset.bottom);
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
    CGSize layoutBounds = layout.bounds;
    return CGSizeMake(layoutBounds.width + self.textContainerInset.left + self.textContainerInset.right,
                      layoutBounds.height + self.textContainerInset.top + self.textContainerInset.bottom);
}

- (void)drawRect:(CGRect)rect {
    CGSize boundsSize = self.bounds.size;
    CGSize size = CGSizeMake(boundsSize.width - self.textContainerInset.left - self.textContainerInset.right,
                             boundsSize.height - self.textContainerInset.top - self.textContainerInset.bottom);
    CGPoint pos = CGPointMake(self.textContainerInset.left, self.textContainerInset.top);
    
    if (_needReDetectLink) {
        _dataDetectorMatchResults = nil;
        if (_dataDetectorTypes == UIDataDetectorTypeNone) {
            _needReDetectLink = NO;
        } else {
            if (_asyncDataDetector) {
                __weak typeof(self) wself = self;
                int sessionID = self.dataDetectorRefreshSessionID;
                MDLDataDetectorOperation *operation = [[MDLDataDetectorOperation alloc] init];
                operation.customDetector = self.customDataDetector;
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
                NSString *string = [_innerAttributedString string];
                NSArray *matches = [self matchResultsInString:string withDataDetector:_dataDetectorTypes];
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
                        value.userInfo = @{@"NSTextCheckingResult" : match };
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
        _textContainer.lineBreakMode = self.lineBreakMode;
        
        _layout = [MDLLabelLayout labelLayoutWithAttributedText:mutableAttributedText textContainer:_textContainer];
        _layout.drawPosition = pos;
    }
    
    NSRange range = [_layout.layoutManager glyphRangeForTextContainer:_layout.textContainer];
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
                             if (attachment.imageView || attachment.customImage) {
                                 NSParagraphStyle *paragraphStyle = [_layout.textStorage mdl_paragraphStyleAtIndex:range.location];
                                 CGFloat lineSpacing = paragraphStyle.lineSpacing;
                                 
                                 NSRange glyphRange = [_layout.layoutManager glyphRangeForCharacterRange:range
                                                                                    actualCharacterRange:NULL];
                                 CGSize size = [_layout.layoutManager attachmentSizeForGlyphAtIndex:glyphRange.location];
                                 CGRect frame = [_layout.layoutManager boundingRectForGlyphRange:glyphRange
                                                                                 inTextContainer:_layout.textContainer];
                                 
                                 frame = CGRectOffset(frame, pos.x, pos.y);
                                 frame.origin.y += frame.size.height - size.height - lineSpacing;
                                 frame.size = size;
                                 
                                 if (attachment.imageView) {
                                     attachment.imageView.frame = frame;
                                     [self addSubview:attachment.imageView];
                                     [attachment.imageView startAnimating];
                                 } else {
                                     [attachment.customImage drawInRect:frame];
                                 }
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
    // Fill used rect only or background color will beyond the trailing (when lineBreakMode is NSLineBreakByWordWrapping)
    
    NSRange glyphRange = [self glyphRangeForCharacterRange:charRange actualCharacterRange:NULL];
#ifdef DEBUG
    NSLog(@"text %@ in range %@ count:%@", [self.textStorage attributedSubstringFromRange:charRange].string, NSStringFromRange(charRange), @(rectCount));
#endif
    __block NSUInteger rectIndex = 0;
    NSMutableArray *mutableRects = [NSMutableArray array];
    [self enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        CGRect usedRectAfterApplyEdgeInset = CGRectOffset(usedRect, self.drawPosition.x, self.drawPosition.y);
        while (rectIndex < rectCount) {
            CGRect rectOri = rectArray[rectIndex];
            CGRect rectResult = CGRectIntersection(rectOri, usedRectAfterApplyEdgeInset);
#ifdef DEBUG
            NSRange actualGlyphRange;
            NSRange debugLineCharRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:&actualGlyphRange];
            NSAssert(NSEqualRanges(actualGlyphRange, glyphRange), @"");
            NSString *currentLineStr = [self.textStorage attributedSubstringFromRange:debugLineCharRange].string;
            NSLog(@"index %@, line string:%@, rect:%@, usedRect:%@", @(rectIndex), currentLineStr, NSStringFromCGRect(rect), NSStringFromCGRect(usedRect));
            NSLog(@"usedRectAfterApplyEdgeInset:%@, ori:%@, result:%@", NSStringFromCGRect(usedRectAfterApplyEdgeInset), NSStringFromCGRect(rectOri), NSStringFromCGRect(rectResult));
#endif
            if (rectResult.size.width == 0 ||
                rectResult.size.height == 0) {
                // This line doesn't contain rect result, get next result
                ++rectIndex;
            } else {
                // This line contains rect result, get next line fragments. Don't move forward rectIndex because the rectIndex may contain multiple lines
                NSRange charRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
                if (charRange.location + charRange.length + 1 < self.textStorage.length) {
                    NSParagraphStyle *par = [self.textStorage mdl_paragraphStyleAtIndex:charRange.location];
                    rectResult.size.height -= par.lineSpacing;
                }
                [mutableRects addObject:[NSValue valueWithCGRect:rectResult]];
                break;
            }
        }
    }];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (NSValue *valueRect in mutableRects) {
        CGRect rect = [valueRect CGRectValue];
        CGRect rectAfter = [self normalizeRect:rect];
        NSLog(@"fill rect : %@, after :%@", NSStringFromCGRect(rect), NSStringFromCGRect(rectAfter));
        CGContextFillRect(ctx, rectAfter);
    }
}

- (CGRect)normalizeRect:(CGRect)rect {
    CGFloat scale = 2;
    CGFloat fBottom = rect.origin.y + rect.size.height;
    // top
    long long top = (long long)((rect.origin.y + 1/scale) * scale);
    CGFloat f = top/scale;
    rect.origin.y = f;
    // bottom
    long long bottom = (fBottom + 1/scale) * scale;
    f = bottom/scale;
    rect.size.height = f - rect.origin.y;
    return rect;
}

@end

