//
//  CCTextContainer.m
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextContainer.h"

const CGFloat CCTextMaxContainerWidth = 9999.0;
const CGFloat CCTextMaxContainerHeight = 9999.0;

@implementation CCTextContainer

+ (CCTextContainer *)textContainerWithContentSize:(CGSize)contentSize contentInsets:(UIEdgeInsets)contentInsets {
    CCTextContainer *container = [[CCTextContainer alloc] initWithContentSize:contentSize contentInsets:contentInsets];
    return container;
}

- (id)initWithContentSize:(CGSize)contentSize contentInsets:(UIEdgeInsets)contentInsets {
    self = [super init];
    if (self) {
        _contentSize = contentSize;
        if (_contentSize.width > CCTextMaxContainerWidth) {
            _contentSize.width = CCTextMaxContainerWidth;
        }
        if (_contentSize.height > CCTextMaxContainerHeight) {
            _contentSize.height = CCTextMaxContainerHeight;
        }
        _contentInsets = contentInsets;
        _useEvenOddFillPathRule = YES;
        _maxNumberOfLines = 0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CCTextContainer *container = [[CCTextContainer alloc] initWithContentSize:self.contentSize contentInsets:self.contentInsets];
    container.useEvenOddFillPathRule = self.useEvenOddFillPathRule;
    container.exclusionPaths = [self.exclusionPaths copy];
    container.pathWidth = self.pathWidth;
    container.maxNumberOfLines = self.maxNumberOfLines;
    container.truncationToken = [self.truncationToken copy];
    return container;
}

@end
