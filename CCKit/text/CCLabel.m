//
//  CCLabel.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCLabel.h"
#import "CCKitMacro.h"
#import "UIView+CCKit.h"
#import "NSAttributedString+CCKit.h"
#import "CCTextDefine.h"

@implementation CCLabel {
    BOOL _needUpdateLayout;
    NSMutableAttributedString *_innerAttributedString;
    CCTextContainer *_textContainer;
    
    NSDictionary *_textHighlightedAttributeSaved;
    CCTextHighlighted *_textHighlighted;
    NSRange _effectiveRangeTextHighlighted;
    
    NSArray<CCTextAttachment *> *_attachmentViews;
    NSArray<CCTextAttachment *> *_attachmentLayers;
}

+ (UIFont *)defaultLabelFont {
    return [UIFont systemFontOfSize:17.0];
}

+ (UIColor *)defaultLabelColor {
    return [UIColor blackColor];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CCAsyncLayer *layer = (CCAsyncLayer *)self.layer;
        layer.asyncDisplay = YES;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _textContainer = [CCTextContainer textContainerWithContentSize:CGSizeMake(self.width, self.height) contentInsets:UIEdgeInsetsZero];
    
    _font = [CCLabel defaultLabelFont];
    _textColor = [CCLabel defaultLabelColor];
    _textAlignment = NSTextAlignmentNatural;
    
    _innerAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [_innerAttributedString cc_setFont:_font];
    [_innerAttributedString cc_setColor:_textColor];
    [_innerAttributedString cc_setAlignment:_textAlignment];
    
    _verticleAlignment = CCTextVerticalAlignmentCenter;
}

- (void)extractValueFromTextLayout:(CCTextLayout *)textLayout {
    self.attributedText = textLayout.attributedString;
    _textContainer = [textLayout.textContainer copy];
    self.size = _textContainer.contentSize;
}

#pragma mark - setter and getter

- (CCAsyncLayer *)asyncLayer {
    return (CCAsyncLayer *)self.layer;
}

- (void)setAsyncDisplay:(BOOL)asyncDisplay {
    [self asyncLayer].asyncDisplay = asyncDisplay;
}

- (void)setFont:(UIFont *)font {
    if ([_font isEqual:font]) return;
    _font = font;
    [_innerAttributedString cc_setFont:_font];
    [self _setNeedsUpdateLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    if ([_textColor isEqual:textColor]) return;
    _textColor = textColor;
    [_innerAttributedString cc_setColor:textColor];
    [self _setNeedsUpdateDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    _textAlignment = textAlignment;
    [_innerAttributedString cc_setAlignment:textAlignment];
    
    [self _setNeedsUpdateLayout];
}

- (NSString *)text {
    return [_innerAttributedString string];
}

- (void)setText:(NSString *)text {
    if ([self.text isEqualToString:text]) return;
    
    _innerAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [_innerAttributedString cc_setColor:_textColor];
    [_innerAttributedString cc_setFont:_font];
    
    [self _setNeedsUpdateLayout];
}

- (NSAttributedString *)attributedText {
    return [_innerAttributedString copy];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _innerAttributedString = [attributedText mutableCopy];
    
    _textColor = [_innerAttributedString cc_color];
    _font = [_innerAttributedString cc_font];
    
    [self _setNeedsUpdateLayout];
}

- (void)setVerticleAlignment:(CCTextVerticalAlignment)verticleAlignment {
    if (_verticleAlignment == verticleAlignment) return;
    _verticleAlignment = verticleAlignment;
    
    [self _setNeedsUpdateLayout];
}

- (void)setTextLayout:(CCTextLayout *)textLayout {
    _textLayout = textLayout;
    [self extractValueFromTextLayout:_textLayout];
    
    [self _setNeedsUpdateLayout];
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    if (CGRectEqualToRect(oldFrame, frame)) return;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oldFrame.size, frame.size)) {
        _textContainer.contentSize = frame.size;
        [self _setNeedsUpdateLayout];
    }
}

#pragma mark - from CCTextContainer

- (UIEdgeInsets)contentInsets {
    return _textContainer.contentInsets;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContainer.contentInsets, contentInsets)) return;
    _textContainer.contentInsets = contentInsets;
    
    [self _setNeedsUpdateLayout];
}

- (NSInteger)numberOfLines {
    return _textContainer.maxNumberOfLines;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if (_textContainer.maxNumberOfLines == numberOfLines) return;
    _textContainer.maxNumberOfLines = numberOfLines;
    
    [self _setNeedsUpdateLayout];
}

- (NSAttributedString *)truncationToken {
    return _textContainer.truncationToken;
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    if ([_textContainer.truncationToken isEqualToAttributedString:truncationToken]) return;
    _textContainer.truncationToken = truncationToken;
    
    [self _setNeedsUpdateLayout];
}

- (BOOL)useEvenOddFillPathRule {
    return _textContainer.useEvenOddFillPathRule;
}

- (void)setUseEvenOddFillPathRule:(BOOL)useEvenOddFillPathRule {
    if (_textContainer.useEvenOddFillPathRule != useEvenOddFillPathRule) {
        _textContainer.useEvenOddFillPathRule = useEvenOddFillPathRule;
        
        [self _setNeedsUpdateLayout];
    }
}

- (void)setExclusionPaths:(NSArray<UIBezierPath *> *)exclusionPaths {
    if (!exclusionPaths) {
        exclusionPaths = @[];
    }
    if (![_exclusionPaths isEqualToArray:exclusionPaths]) {
        _exclusionPaths = [exclusionPaths copy];
        
        [self _setNeedsUpdateLayout];
    }
}

- (CGFloat)pathWidth {
    return _textContainer.pathWidth;
}

- (void)setPathWidth:(CGFloat)pathWidth {
    if (_textContainer.pathWidth != pathWidth) {
        _textContainer.pathWidth = pathWidth;
        
        [self _setNeedsUpdateLayout];
    }
}

#pragma mark -

- (void)_clearContents {
//    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
//    if (image) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            CFRelease(image);
//        });
//    }
}

// 不用改变布局，比如text颜色变化，作为优化，现在还是完全重新绘制布局
- (void)_setNeedsUpdateDisplay {
    _needUpdateLayout = YES;
    [self _clearContents];
    [self.layer setNeedsDisplay];
}

- (void)_setNeedsUpdateLayout {
    _needUpdateLayout = YES;
    [self _clearContents];
    [self.layer setNeedsDisplay];
}

+ (Class)layerClass {
    return [CCAsyncLayer class];
}

- (CGPoint)convertPoint:(CGPoint)point toTextLayout:(CCTextLayout *)layout {
    CGFloat offsetY = 0;
    if (_verticleAlignment == CCTextVerticalAlignmentCenter) {
        offsetY = (self.height - layout.contentBounds.height)/2;
    } else if (_verticleAlignment == CCTextVerticalAlignmentBottom) {
        offsetY = self.height - layout.contentBounds.height;
    }
    point = CGPointMake(point.x, point.y - offsetY);
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, layout.textBounds.height);
    transform = CGAffineTransformScale(transform, 1, -1);
    point = CGPointApplyAffineTransform(point, transform);
    return point;
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint position = [[touches anyObject] locationInView:self];
    NSLog(@"ori pos:%@", NSStringFromCGPoint(position));
    position = [self convertPoint:position toTextLayout:_textLayout];
    NSLog(@"text layout pos:%@", NSStringFromCGPoint(position));
    NSInteger index = [_textLayout stringIndexAtPosition:position];
    NSLog(@"index:%@", @(index));
    if (index == NSNotFound) {
        return;
    }
    CCTextHighlighted *textHighlighted = [_innerAttributedString attribute:CCHighlightedAttributeName
                                                                   atIndex:index longestEffectiveRange:&_effectiveRangeTextHighlighted
                                                                   inRange:NSMakeRange(0, [_innerAttributedString length])];
    _textHighlighted = textHighlighted;
    if (textHighlighted) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        [_innerAttributedString enumerateAttributesInRange:_effectiveRangeTextHighlighted options:0 usingBlock:^(NSDictionary<NSString *,id> *attrs, NSRange range, BOOL *stop) {
            NSValue *valueRange = [NSValue valueWithRange:range];
            mutableDict[valueRange] = attrs;
        }];
        _textHighlightedAttributeSaved = [mutableDict copy];
        [textHighlighted.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [_innerAttributedString addAttribute:key value:obj range:_effectiveRangeTextHighlighted];
        }];
        [self _setNeedsUpdateDisplay];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_textHighlighted) {
        // restore
        [_textHighlightedAttributeSaved enumerateKeysAndObjectsUsingBlock:^(NSValue *key, id obj, BOOL * _Nonnull stop) {
            NSRange range = [key rangeValue];
            [_innerAttributedString setAttributes:obj range:range];
        }];
        [self _setNeedsUpdateDisplay];
        
        BOOL touchUpInside = NO;
        CGPoint position = [[touches anyObject] locationInView:self];
        position = [self convertPoint:position toTextLayout:_textLayout];
        NSInteger index = [_textLayout stringIndexAtPosition:position];
        if (index != NSNotFound) {
            if (index >= _effectiveRangeTextHighlighted.location &&
                index < _effectiveRangeTextHighlighted.location + _effectiveRangeTextHighlighted.length) {
                touchUpInside = YES;
            }
        }
        if (touchUpInside) {
            _textHighlighted.tapAction(_effectiveRangeTextHighlighted);
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (_textHighlighted) {
        // restore
        [_textHighlightedAttributeSaved enumerateKeysAndObjectsUsingBlock:^(NSValue *key, id obj, BOOL * _Nonnull stop) {
            NSRange range = [key rangeValue];
            [_innerAttributedString setAttributes:obj range:range];
        }];
        [self _setNeedsUpdateDisplay];
    }
}

#pragma mark - CCAsyncLayerDelegate

- (CCAsyncLayerDisplayTask *)newAsyncDisplayTask {
    BOOL needUpdateLayout = _needUpdateLayout;
    CCTextVerticalAlignment verticleAlignment = _verticleAlignment;
    NSAttributedString *attributedString = [_innerAttributedString copy];
    CGSize labelSize = self.size;
    __block CCTextLayout *layout = _textLayout;
    
    CCAsyncLayerDisplayTask *task = [CCAsyncLayerDisplayTask new];
    task.willDisplay = ^(CALayer *layer) {
        if (needUpdateLayout) {
            for (CCTextAttachment *attachment in _attachmentViews) {
                UIView *v = attachment.content;
                [v removeFromSuperview];
            }
            for (CCTextAttachment *attachment in _attachmentLayers) {
                CALayer *layer = attachment.content;
                [layer removeFromSuperlayer];
            }
            
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (UIBezierPath *path in _exclusionPaths) {
                UIBezierPath *pathCopy = [path copy];
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0, labelSize.height);
                transform = CGAffineTransformScale(transform, 1, -1);
                [pathCopy applyTransform:transform];
                [mutableArray addObject:pathCopy];
            }
            _textContainer.exclusionPaths = [mutableArray copy];
        }
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        if (needUpdateLayout) {
            layout = [CCTextLayout textLayoutWithContainer:_textContainer attributedText:attributedString];
        }
        CGPoint position = CGPointZero;
        if (verticleAlignment == CCTextVerticalAlignmentCenter) {
            position.y = (labelSize.height - layout.contentBounds.height)/2;
        } else if (verticleAlignment == CCTextVerticalAlignmentTop) {
            position.y = labelSize.height - layout.contentBounds.height;
        }
        [layout drawInContext:context view:nil layer:nil position:position size:size isCanceled:isCancelled];
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        CCMainThreadBlock(^() {
            CGPoint position = CGPointZero;
            if (verticleAlignment == CCTextVerticalAlignmentCenter) {
                position.y = (labelSize.height - layout.contentBounds.height)/2;
            } else if (verticleAlignment == CCTextVerticalAlignmentTop) {
                position.y = labelSize.height - layout.contentBounds.height;
            }
            [layout drawInContext:nil view:self layer:self.layer position:position size:labelSize isCanceled:nil];
            
            NSMutableArray *attachViews = [NSMutableArray array];
            NSMutableArray *attachLayers = [NSMutableArray array];
            for (CCTextAttachment *attachment in layout.attachments) {
                if ([attachment.content isKindOfClass:[UIView class]]) {
                    [attachViews addObject:attachment];
                } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                    [attachLayers addObject:attachment];
                }
            }
            _attachmentViews = [attachViews copy];
            _attachmentLayers = [attachLayers copy];
            _needUpdateLayout = NO;
            _textLayout = layout;
        });
    };
    return task;
}

@end
