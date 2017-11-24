//
//  CCTextDefine.m
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCTextDefine.h"

const NSString *const CCAttachmentCharacter = @"\ufffc";

NSString *const CCAttachmentAttributeName = @"CCKit_AttachmentAttributeName";
NSString *const CCHighlightedAttributeName = @"CCKit_HighlightedAttributeName";
NSString *const CCBackgroundColorAttributeName = @"CCKit_BackgroundColorAttributeName";

@implementation CCTextAttachment

+ (id)textAttachmentWithContent:(id)content {
    CCTextAttachment *attachment = [[CCTextAttachment alloc] init];
    attachment.content = content;
    return attachment;
}

- (id)init {
    self = [super init];
    if (self) {
        _content = nil;
        _contentInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setContent:(id)content {
    _content = content;
    
    CGSize size = CGSizeZero;
    if ([content isKindOfClass:[UIView class]]) {
        size = ((UIView *)content).frame.size;
    } else if ([content isKindOfClass:[CALayer class]]) {
        size = ((CALayer *)content).frame.size;
    } else if ([content isKindOfClass:[UIImage class]]) {
        size = ((UIImage *)content).size;
    } else {
        NSAssert(NO, @"don't support the attachment type");
        size = CGSizeZero;
    }
    _contentSize = size;
}

@end


@implementation CCTextHighlighted

- (NSDictionary *)attributes {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    if (_bgColor) {
        mutableDictionary[CCBackgroundColorAttributeName] = _bgColor;
    }
    if (_highlightedColor) {
        mutableDictionary[NSForegroundColorAttributeName] = _highlightedColor;
    }
    return [mutableDictionary copy];
}

@end
