//
//  TextKitView.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/16.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKitView.h"
#import "MDLMessageTextStorage.h"
#import "TextLayoutManager.h"

typedef NS_ENUM(NSUInteger, MDLTextKitTouchViewStatus) {
    MDLTextKitTouchViewStatusDownInside,
    MDLTextKitTouchViewStatusMoveInside,
    MDLTextKitTouchViewStatusMoveOutside,
    MDLTextKitTouchViewStatusUpInside,
    MDLTextKitTouchViewStatusUpOutside,
};


@interface TextKitView () <NSLayoutManagerDelegate>

@property (nonatomic) NSRange effectiveRangeTextHighlighted;
@property (nonatomic) NSDictionary *textHighlightedAttributeSaved;
@property (nonatomic) MDLMessageTextHighlightedValue *textHighlighted;


@property (nonatomic) CGSize intrinsicSize;
@property (nonatomic) NSTextContainer *textContainer;
@property (nonatomic) MDLMessageTextStorage *storage;
@property (nonatomic) TextLayoutManager *layoutManager;

@end

@implementation TextKitView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    if (!_layoutManager) {
        return CGSizeZero;
    } else {
        return self.intrinsicSize;
    }
}

- (void)setAttrText:(NSAttributedString *)attrText {
    _attrText = [attrText copy];
    
    if (_attrText) {
        if (!_storage) {
            _storage = [[NSTextStorage alloc] initWithAttributedString:_attrText];
        } else {
            [_storage replaceCharactersInRange:NSMakeRange(0, _storage.length) withAttributedString:_attrText];
        }
        
        if (!_layoutManager) {
            _layoutManager = [[TextLayoutManager alloc] init];
            _layoutManager.delegate = self;
            [_storage addLayoutManager:_layoutManager];
        }
        
        if (!_textContainer) {
            _textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width, 200)];
            _textContainer.maximumNumberOfLines = 1;
            _textContainer.lineBreakMode = NSLineBreakByTruncatingHead;
            [_layoutManager addTextContainer:_textContainer];
        } else {
            _textContainer.size = CGSizeMake(self.bounds.size.width, 200);
        }
        NSLog(@"start");
        
        NSRange range = [_layoutManager glyphRangeForTextContainer:_textContainer];
        CGRect rect = [_layoutManager boundingRectForGlyphRange:range inTextContainer:_textContainer];
        self.intrinsicSize = CGSizeMake(ceil(rect.origin.x*2 + rect.size.width), ceil(rect.size.height));
        NSLog(@"%@", NSStringFromCGRect(rect));
        
        rect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(0, 1) inTextContainer:_textContainer];
        NSLog(@"%@", NSStringFromCGRect(rect));
        
        rect = [_layoutManager boundingRectForGlyphRange:range inTextContainer:_textContainer];
        
        [self invalidateIntrinsicContentSize];
    } else {
        _storage = nil;
        _layoutManager = nil;
        _textContainer = nil;
    }
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.storage enumerateAttribute:MDLMessageTextBackgroundColorAttributeName inRange:NSMakeRange(0, self.storage.length) options:0 usingBlock:^(id obj, NSRange range, BOOL * _Nonnull stop) {
        if (!obj) {
            return;
        }
        
        NSDictionary *dict = [self.storage attributesAtIndex:range.location effectiveRange:NULL];
        UIColor *color = dict[MDLMessageTextBackgroundColorAttributeName];
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        [_layoutManager enumerateEnclosingRectsForGlyphRange:range withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textContainer usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
            NSLog(@"enclosing:%@", NSStringFromCGRect(rect));
            CGContextFillRect(ctx, rect);
        }];
    }];
    
    // draw highlighted string
    
    if (_layoutManager) {
        [_layoutManager drawGlyphsForGlyphRange:NSMakeRange(0, self.storage.length) atPoint:CGPointZero];
    }
}

#pragma mark - NSLayoutManagerDelegate -- Line layout


/************************ Line layout ************************/
// These methods are invoked while each line is laid out.  They allow NSLayoutManager delegate to customize the shape of line.

/*
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    unichar c = [self.storage.string characterAtIndex:glyphIndex];
    NSString *str = [NSString stringWithCharacters:&c length:1];
    NSLog(@"%@, %@, %@", NSStringFromSelector(_cmd), str, NSStringFromCGRect(rect));
    return 1;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingBeforeGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    unichar c = [self.storage.string characterAtIndex:glyphIndex];
    NSString *str = [NSString stringWithCharacters:&c length:1];
    NSLog(@"%@, %@, %@", NSStringFromSelector(_cmd), str, NSStringFromCGRect(rect));
    return 1;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    unichar c = [self.storage.string characterAtIndex:glyphIndex];
    NSString *str = [NSString stringWithCharacters:&c length:1];
    NSLog(@"%@, %@, %@", NSStringFromSelector(_cmd), str, NSStringFromCGRect(rect));
    return 1;
}

- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager shouldUseAction:(NSControlCharacterAction)action forControlCharacterAtIndex:(NSUInteger)charIndex {
    NSLog(@"%@, %@, %@", NSStringFromSelector(_cmd), @(charIndex), @(action));
    return action;
}*/

/*
// Invoked while determining the soft line break point.  When NO, NSLayoutManager tries to find the next line break opportunity before charIndex
- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex NS_AVAILABLE(10_11, 7_0);

// Invoked while determining the hyphenation point.  When NO, NSLayoutManager tries to find the next hyphenation opportunity before charIndex
- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex NS_AVAILABLE(10_11, 7_0);
*/


// Invoked for resolving the glyph metrics for NSControlCharacterWhitespaceAction control character.
// - (CGRect)layoutManager:(NSLayoutManager *)layoutManager boundingBoxForControlGlyphAtIndex:(NSUInteger)glyphIndex forTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedRect glyphPosition:(CGPoint)glyphPosition characterIndex:(NSUInteger)charIndex {}


// Allows NSLayoutManagerDelegate to customize the line fragment geometry before committing to the layout cache. The implementation of this method should make sure that the modified fragments are still valid inside the text container coordinate. When it returns YES, the layout manager uses the modified rects. Otherwise, it ignores the rects returned from this method.
//- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange {}


#pragma mark - NSLayoutManagerDelegate -- Layout processing

- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// This is sent whenever a container has been filled.  This method can be useful for paginating.  The textContainer might be nil if we have completed all layout and not all of it fit into the existing containers.  The atEnd flag indicates whether all layout is complete.
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    NSLog(@"%@, text container:%@, atEnd:%@", NSStringFromSelector(_cmd), textContainer, @(layoutFinishedFlag));
}

// This is sent right before layoutManager invalidates the layout due to textContainer changing geometry.  The receiver of this method can react to the geometry change and perform adjustments such as recreating the exclusion path.
- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    NSUInteger index = [_layoutManager glyphIndexForPoint:p inTextContainer:self.textContainer];
    
    MDLMessageTextHighlightedValue *textHighlighted = [self.storage attribute:MDLMessagetextHighlightedAttributeName
                                                                   atIndex:index
                                                        longestEffectiveRange:&_effectiveRangeTextHighlighted
                                                                   inRange:NSMakeRange(0, [self.storage length])];
    _textHighlighted = textHighlighted;
    if (textHighlighted) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        [self.storage enumerateAttributesInRange:_effectiveRangeTextHighlighted options:0 usingBlock:^(NSDictionary<NSString *,id> *attrs, NSRange range, BOOL *stop) {
            NSValue *valueRange = [NSValue valueWithRange:range];
            mutableDict[valueRange] = attrs;
        }];
        _textHighlightedAttributeSaved = [mutableDict copy];
        [_textHighlighted.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [self.storage addAttribute:key value:obj range:_effectiveRangeTextHighlighted];
        }];
        
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (_textHighlighted) {
        // restore
        [_textHighlightedAttributeSaved enumerateKeysAndObjectsUsingBlock:^(NSValue *key, id obj, BOOL * _Nonnull stop) {
            NSRange range = [key rangeValue];
            [self.storage setAttributes:obj range:range];
        }];
        
        [self setNeedsDisplay];
        
        BOOL touchUpInside = NO;
        CGPoint position = [[touches anyObject] locationInView:self];
        NSInteger index = [_layoutManager glyphIndexForPoint:position inTextContainer:self.textContainer];
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

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (_textHighlighted) {
        // restore
        [_textHighlightedAttributeSaved enumerateKeysAndObjectsUsingBlock:^(NSValue *key, id obj, BOOL * _Nonnull stop) {
            NSRange range = [key rangeValue];
            [self.storage setAttributes:obj range:range];
        }];
        [self setNeedsDisplay];
    }
}

@end
