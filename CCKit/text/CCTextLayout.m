//
//  CCTextLayout.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextLayout.h"
#import "CCTextDefine.h"
#import "UIView+CCKit.h"
#import "CCKitMacro.h"
#import "NSAttributedString+CCKit.h"

@implementation CCTextLayout {
    CTFramesetterRef _ctFramesetter;
    CTFrameRef _ctFrame;
}

+ (id)textLayoutWithSize:(CGSize)size text:(NSString *)text {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
    return [self textLayoutWithSize:size attributedText:attributedString];
}

+ (id)textLayoutWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText {
    CCTextContainer *container = [CCTextContainer textContainerWithContentSize:size contentInsets:UIEdgeInsetsZero];
    return [self textLayoutWithContainer:container attributedText:attributedText];
}

+ (id)textLayoutWithContainer:(CCTextContainer *)textContainer text:(NSString *)text {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
    return [self textLayoutWithContainer:textContainer attributedText:attributedString];
}

+ (id)textLayoutWithContainer:(CCTextContainer *)textContainer attributedText:(NSAttributedString *)attributedText {
    CCTextLayout *textLayout = [[CCTextLayout alloc] initWithContainer:textContainer attributedString:attributedText];
    return textLayout;
}

+ (CGSize)textBoundsOfFrame:(CTFrameRef)frame {
    CGPathRef framePath = CTFrameGetPath(frame);
    CGRect frameRect = CGPathGetBoundingBox(framePath);
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex numLines = CFArrayGetCount(lines);
    CGFloat maxWidth = 0;
    CGFloat textHeight = 0;
    CFIndex lastLineIndex = numLines - 1;
    
    CGPoint origins[numLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    for (CFIndex index = 0; index < numLines; index++) {
        CGFloat ascent, descent, leading, width;
        CTLineRef line = (CTLineRef) CFArrayGetValueAtIndex(lines, index);
        width = CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);
        // when we set any indent related property of NSParagraphStyle, origin.x of line will be great than 0.
        width += origins[index].x > 0 ? origins[index].x : 0;
        if (width > maxWidth) { maxWidth = width; }
        if (index == lastLineIndex) {
            CGPoint lastLineOrigin = origins[index];
            textHeight = CGRectGetHeight(frameRect) - (lastLineOrigin.y - descent - leading);
        }
    }
    return CGSizeMake(ceil(maxWidth), ceil(textHeight));
}

+ (CGSize)textBoundsOfLines:(NSArray<CCTextLine *> *)lines {
    CGFloat maxWidth = 0;
    CGFloat textHeight = 0;
    if (lines.count > 0) {
        CGRect frameFirstLine = lines.firstObject.frame;
        CGRect frameLastLine = lines.lastObject.frame;
        textHeight = CGRectGetMaxY(frameFirstLine)-CGRectGetMinY(frameLastLine);
        for (CCTextLine *line in lines) {
            if (CGRectGetMaxX(line.frame) > maxWidth) {
                maxWidth = CGRectGetMaxX(line.frame);
            }
        }
    }
    return CGSizeMake(ceil(maxWidth), ceil(textHeight));
}

- (void)dealloc {
    if (_ctFramesetter) {
        CFRelease(_ctFramesetter);
    }
}

- (id)initWithContainer:(CCTextContainer *)container attributedString:(NSAttributedString *)attributedText {
    self = [super init];
    if (self) {
        _textContainer = container;
        _attributedString = attributedText;
        
        [self layout];
    }
    return self;
}

- (void)layout {
    CGRect textFrame = CGRectMake(0, 0, _textContainer.contentSize.width, _textContainer.contentSize.height);
    if (!UIEdgeInsetsEqualToEdgeInsets(_textContainer.contentInsets, UIEdgeInsetsZero)) {
        textFrame = UIEdgeInsetsInsetRect(textFrame, _textContainer.contentInsets);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, _textContainer.contentSize.height);
        transform = CGAffineTransformScale(transform, 1, -1);
        textFrame = CGRectApplyAffineTransform(textFrame, transform);
    }
    UIBezierPath *textConstraintPath = [UIBezierPath bezierPathWithRect:textFrame];
    if ([_textContainer.exclusionPaths count] > 0) {
        for (UIBezierPath *path in _textContainer.exclusionPaths) {
            [textConstraintPath appendPath:path];
        }
    }
    
    NSMutableDictionary *frameAttribute = [NSMutableDictionary dictionary];
    if (!_textContainer.useEvenOddFillPathRule) {
        frameAttribute[(__bridge NSString *)kCTFramePathFillRuleAttributeName] = @(kCTFramePathFillWindingNumber);
    }
    if (_textContainer.pathWidth > 0) {
        frameAttribute[(__bridge NSString *)kCTFramePathWidthAttributeName] = @(_textContainer.pathWidth);
    }
    
    CGRect boundingBox = CGPathGetBoundingBox(textConstraintPath.CGPath);
    _ctFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
    _ctFrame = CTFramesetterCreateFrame(_ctFramesetter, CFRangeMake(0, 0), textConstraintPath.CGPath, (__bridge CFDictionaryRef)frameAttribute);
    
    // if the path(textConstraintPath.CGPath) can't wrap all the content of attributed text, CTFrameGetLines just returns the visiable lines
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    CFIndex count = CFArrayGetCount(lines);
    NSMutableArray *mutableLines = [NSMutableArray array];
    BOOL needTruncate = NO;
    if (count > 0) {
        CGPoint positions[count];
        // the position is the relative position to the path(the path of CTFramesetterCreateFrame's third paramter)'s bounding box
        // position at 0 is the topest line
        CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), positions);
        
        NSInteger bottomLineIndex = count-1;
        if (_textContainer.maxNumberOfLines != 0 && count > _textContainer.maxNumberOfLines) {
            needTruncate = YES;
            bottomLineIndex = _textContainer.maxNumberOfLines-1;
        }
        
        CTLineRef bottomLine = CFArrayGetValueAtIndex(lines, bottomLineIndex);
        CGPoint bottomPosition = positions[bottomLineIndex];
        CGFloat bottomLineDescent, bottomLineLeading;
        CTLineGetTypographicBounds(bottomLine, NULL, &bottomLineDescent, &bottomLineLeading);
        CGFloat bottom = bottomPosition.y - bottomLineDescent - bottomLineLeading;
        
        for (CFIndex i = 0; i <= bottomLineIndex; ++i) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CGPoint origin = positions[i];
            origin = CGPointMake(origin.x+boundingBox.origin.x, origin.y-bottom+boundingBox.origin.y);
            CGFloat lineAscent = 0, lineDescent = 0, lineLeading = 0;
            CGFloat width = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            CGRect frame = CGRectMake(origin.x, origin.y-lineDescent-lineLeading, width, lineAscent+lineDescent+lineLeading);
            CCTextLine *ccLine = [CCTextLine textLineWithOrigin:origin frame:frame line:line];
            [mutableLines addObject:ccLine];
        }
    }
    
    // check if the CTFrame contain all the text
    if (!needTruncate) {
        CFRange visibleRange = CTFrameGetVisibleStringRange(_ctFrame);
        if (visibleRange.length < _attributedString.length) {
            needTruncate = YES;
        }
    }
    
    
    if (needTruncate && [mutableLines count] > 0) {
        NSAttributedString *truncationToken = _textContainer.truncationToken ?: [NSAttributedString cc_attributedStringWithString:@"..."];
        CCTextLine *textLine = [mutableLines lastObject];
        double lineWidth = CTLineGetTypographicBounds(textLine.line, NULL, NULL, NULL) - CTLineGetTrailingWhitespaceWidth(textLine.line);
        CTLineRef lineTruncationToken = CTLineCreateWithAttributedString((__bridge CFTypeRef)truncationToken);
        CTLineRef lineAfterTruncation = CTLineCreateTruncatedLine(textLine.line, lineWidth-1, kCTLineTruncationEnd, lineTruncationToken);
        if (lineAfterTruncation) {
            CGPoint origin = textLine.origin;
            CGFloat lineAscent = 0, lineDescent = 0, lineLeading = 0;
            CGFloat width = CTLineGetTypographicBounds(lineAfterTruncation, &lineAscent, &lineDescent, &lineLeading);
            CGRect frame = CGRectMake(origin.x, origin.y-lineDescent-lineLeading, width, lineAscent+lineDescent+lineLeading);
            CCTextLine *textLine = [CCTextLine textLineWithOrigin:origin frame:frame line:lineAfterTruncation];
            [mutableLines removeObjectAtIndex:mutableLines.count-1];
            [mutableLines addObject:textLine];
        }
    }
    _textLines = [mutableLines count] > 0 ? [mutableLines copy] : nil;
    
    NSMutableArray *attachments = [NSMutableArray array];
    NSMutableArray *attachmentFrames = [NSMutableArray array];
    for (CCTextLine *textLine in _textLines) {
        [attachments addObjectsFromArray:textLine.attachments];
        [attachmentFrames addObjectsFromArray:textLine.attachmentFrames];
    }
    _attachments = [attachments copy];
    _attachmentFrames = [attachmentFrames copy];
    
    CGSize size = [CCTextLayout textBoundsOfLines:_textLines];
    _textBounds = size;
    _contentBounds = CGSizeMake(_textContainer.contentInsets.left + _textContainer.contentInsets.right + _textBounds.width, _textContainer.contentInsets.top + _textContainer.contentInsets.bottom + _textBounds.height);
}

- (void)drawInContext:(CGContextRef)context
                 view:(UIView *)view layer:(CALayer *)layer
             position:(CGPoint)position size:(CGSize)size
           isCanceled:(BOOL(^)(void))isCanceled {
    /*
    if (context) {
        CGContextSaveGState(context);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGRect frame = CGRectMake(position.x, position.y, _contentBounds.width, _contentBounds.height);
        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextStrokeRect(context, frame);
        
        CGContextRestoreGState(context);
    }*/
    
    if (context) {
        [self drawTextInContext:context position:position size:size isCanceled:isCanceled];
    }
    
    if (view && layer) {
        [self drawViewOrLayerContentAttachmentOnView:view layer:layer position:position size:size];
    }
}

- (void)setLineDashContext:(CGContextRef)context withUnderlineStyle:(NSUnderlineStyle)underlineStyle {
    switch (underlineStyle & 0xff00) {
        case NSUnderlinePatternDot: {
            CGFloat pattern[] = {3, 3};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        case NSUnderlinePatternDash: {
            CGFloat pattern[] = {10, 5};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        case NSUnderlinePatternDashDot: {
            CGFloat pattern[] = {10, 3, 3, 3};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        case NSUnderlinePatternDashDotDot: {
            CGFloat pattern[] = {10, 3, 3, 3, 3, 3};
            CGContextSetLineDash(context, 0, pattern, sizeof(pattern)/sizeof(CGFloat));
        }
            break;
        default:
            break;
    }
}

- (void)drawTextInContext:(CGContextRef)context position:(CGPoint)position size:(CGSize)size isCanceled:(BOOL(^)(void))isCanceled {
    if (isCanceled && isCanceled()) {
        return;
    }
//    position = size.height - (size.height - position);
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    for (CCTextLine *line in _textLines) {
        if (isCanceled && isCanceled()) {
            return;
        }
        
        // draw attachments
        for (NSInteger i = 0; i < [line.attachments count]; ++i) {
            CCTextAttachment *attachment = line.attachments[i];
            CGRect frame = [line.attachmentFrames[i] CGRectValue];
            CGRect frameContainer = CGRectOffset(frame, position.x, position.y);
            frameContainer = UIEdgeInsetsInsetRect(frameContainer, attachment.contentInsets);
            CGRect frameInside = [UIView cc_frameOfContentWithContentSize:attachment.contentSize containerSize:frameContainer.size contentMode:attachment.contentMode];
            frame = CGRectMake(frameContainer.origin.x+frameInside.origin.x, frameContainer.origin.y+frameInside.origin.y, frameInside.size.width, frameInside.size.height);
            if ([attachment.content isKindOfClass:[UIImage class]]) {
                CGContextSaveGState(context);
                CGContextClipToRect(context, frameContainer);
                UIImage *image = (UIImage *)attachment.content;
                CGContextDrawImage(context, frame, image.CGImage);
                CGContextRestoreGState(context);
            }
        }
        
        CGPoint lineOrigin = line.origin;
        lineOrigin = CGPointMake(lineOrigin.x + position.x, lineOrigin.y + position.y);
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        // draw text run
        for (CCTextRun *textRun in line.textRuns) {
            CGRect frame = textRun.frame;
            frame = CGRectOffset(frame, position.x, position.y);
            CTRunRef run = (__bridge CTRunRef)textRun.run;
            NSDictionary *attr = (__bridge id)CTRunGetAttributes(run);
            {// draw background color
                UIColor *bgColor = attr[CCBackgroundColorAttributeName];
                if (bgColor) {
                    CGContextSetFillColorWithColor(context, bgColor.CGColor);
                    CGContextFillRect(context, frame);
                }
            }
            {// draw ctrun
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
            
            {// draw strikethrough line
                [self drawStrikethroughInContext:context run:textRun inFrame:frame];
            }
        }
    }
    CGContextRestoreGState(context);
}

- (void)addStrikethroughLineInContext:(CGContextRef)context fromPosition:(CGPoint)from toPosition:(CGPoint)to {
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
}

- (void)drawStrikethroughInContext:(CGContextRef)context run:(CCTextRun *)textRun inFrame:(CGRect)frame {
    CTRunRef run = (__bridge CTRunRef)textRun.run;
    NSDictionary *attr = (__bridge id)CTRunGetAttributes(run);
    NSNumber *numberStyle = attr[NSStrikethroughStyleAttributeName];
    NSUnderlineStyle style = [numberStyle integerValue];
    if (!numberStyle || (style & 0xff) == NSUnderlineStyleNone) {
        return;
    }
    
    CGContextSaveGState(context);
    // set strikethrough color
    UIColor *strikethroughColor = attr[NSStrikethroughColorAttributeName];
    if (strikethroughColor) {
        CGContextSetStrokeColorWithColor(context, strikethroughColor.CGColor);
    }
    [self setLineDashContext:context withUnderlineStyle:style];
    CGFloat x = frame.origin.x;
    CGFloat centerY = frame.origin.y + frame.size.height/2;
    switch (style & 0xff) {
        case NSUnderlineStyleSingle:
            CGContextSetLineWidth(context, 1);
            break;
        case NSUnderlineStyleDouble: {
            NSInteger pixel = (NSInteger)((2 * [UIScreen mainScreen].scale)/3);
            if (pixel == 0) pixel = 1;
            CGFloat h = PixelToPoint(pixel);
            CGContextSetLineWidth(context, h);
        }
            break;
        case NSUnderlineStyleThick:
            CGContextSetLineWidth(context, 2);
            break;
        default:
            break;
    }
    
    // TODO:NSUnderlineByWord
    // BOOL underLineByWord = (style & 0xff0000) == NSUnderlineByWord;
    CGPoint p0, p1;
    switch (style & 0xff) {
        case NSUnderlineStyleSingle:
            p0 = CGPointMake(x, centerY);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
            break;
        case NSUnderlineStyleDouble: {
            NSInteger pixel = (NSInteger)((2 * [UIScreen mainScreen].scale)/3);
            if (pixel == 0) pixel = 1;
            CGFloat h = PixelToPoint(pixel);
            p0 = CGPointMake(x, centerY-h);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
            p0 = CGPointMake(x, centerY+h);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
        }
            break;
        case NSUnderlineStyleThick: {
            p0 = CGPointMake(x, centerY);
            p1 = CGPointMake(p0.x + frame.size.width, p0.y);
            [self addStrikethroughLineInContext:context fromPosition:p0 toPosition:p1];
        }
            break;
        default:
            break;
    }
    
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawViewOrLayerContentAttachmentOnView:(UIView *)view layer:(CALayer *)layer position:(CGPoint)position size:(CGSize)size {
//    position = size.height - (size.height - position);
    for (CCTextLine *line in _textLines) {
        for (NSInteger i = 0; i < [line.attachments count]; ++i) {
            CCTextAttachment *attachment = line.attachments[i];
            CGRect frame = [line.attachmentFrames[i] CGRectValue];
            frame = CGRectOffset(frame, position.x, position.y);
            frame = UIEdgeInsetsInsetRect(frame, attachment.contentInsets);
            CGRect frameInside = [UIView cc_frameOfContentWithContentSize:attachment.contentSize containerSize:frame.size contentMode:attachment.contentMode];
            frame = CGRectMake(frame.origin.x+frameInside.origin.x, frame.origin.y+frameInside.origin.y, frameInside.size.width, frameInside.size.height);
            if ([attachment.content isKindOfClass:[UIView class]] ||
                [attachment.content isKindOfClass:[CALayer class]]) {
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0, size.height);
                transform = CGAffineTransformScale(transform, 1, -1);
                frame = CGRectApplyAffineTransform(frame, transform);
                if ([attachment.content isKindOfClass:[UIView class]]) {
                    UIView *viewAttachment = (UIView *)attachment.content;
                    [view addSubview:viewAttachment];
                    viewAttachment.frame = frame;
                } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                    CALayer *layerAttachment = attachment.content;
                    [layer addSublayer:layerAttachment];
                    layer.frame = frame;
                }
            }
        }
    }
}

// TODO:when the last run is a image, position is the end + 1. why???
- (NSInteger)stringIndexAtPosition:(CGPoint)position {
    for (CCTextLine *line in _textLines) {
        if (CGRectContainsPoint(line.frame, position)) {
            CGPoint positionInLine = CGPointMake(position.x-line.origin.x, position.y-line.origin.y);
            CFIndex position = CTLineGetStringIndexForPosition(line.line, positionInLine);
            if (position == kCFNotFound) {
                return NSNotFound;
            }
            return (NSInteger)position;
        }
    }
    return NSNotFound;
}

@end
