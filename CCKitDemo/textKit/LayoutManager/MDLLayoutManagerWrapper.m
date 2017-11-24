//
//  MDLLayoutManagerWrapper.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "MDLLayoutManagerWrapper.h"


@interface MDLLayoutManagerWrapper ()

@property (nonatomic) NSTextStorage *textStorage;
@property (nonatomic) NSLayoutManager *layoutManager;
@property (nonatomic) NSTextContainer *textContainer;

@end

@implementation MDLLayoutManagerWrapper

+ (instancetype)layoutManagerWithAttributedString:(NSAttributedString *)attributedString maxSize:(CGSize)size {
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    return [[self alloc] initWithAttributedString:attributedString textContainer:textContainer];
}

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString
                           textContainer:(NSTextContainer *)textContainer {
    self = [super init];
    if (self) {
        _textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        
        _layoutManager = [[NSLayoutManager alloc] init];
        [_textStorage addLayoutManager:_layoutManager];
        
        _textContainer = textContainer;
        [_layoutManager addTextContainer:_textContainer];
    }
    return self;
}

- (CGRect)boundsRect {
    NSRange all = [_layoutManager glyphRangeForTextContainer:_textContainer];
    return [_layoutManager boundingRectForGlyphRange:all inTextContainer:_textContainer];
}

@end
