//
//  CCTextDefine.h
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CCAttachmentCharacter;

typedef void (^CCTapActionBlock)(NSRange range);

typedef NS_ENUM(NSUInteger, CCTextAttachmentPosition) {
    CCTextAttachmentPositionTop,
    CCTextAttachmentPositionCenter,
    CCTextAttachmentPositionBottom
};

typedef NS_ENUM(NSUInteger, CCTextVerticalAlignment) {
    CCTextVerticalAlignmentTop,
    CCTextVerticalAlignmentCenter,
    CCTextVerticalAlignmentBottom
};

extern NSString *const CCAttachmentAttributeName;
extern NSString *const CCHighlightedAttributeName;
extern NSString *const CCBackgroundColorAttributeName;

@interface CCTextAttachment : NSObject

+ (id)textAttachmentWithContent:(id)content;

@property (nonatomic) id content;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) UIEdgeInsets contentInsets;

@end

@interface CCTextHighlighted : NSObject

@property (nonatomic) BOOL enable;
@property (nonatomic) NSDictionary *attributes;
@property (nonatomic) UIColor *bgColor;
@property (nonatomic) UIColor *highlightedColor;
@property (nonatomic, copy) CCTapActionBlock tapAction;

@end