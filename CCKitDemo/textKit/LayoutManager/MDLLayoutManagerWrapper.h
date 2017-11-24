//
//  MDLLayoutManagerWrapper.h
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDLLayoutManagerWrapper : NSObject

@property (nonatomic, readonly) NSTextStorage *textStorage;
@property (nonatomic, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, readonly) NSTextContainer *textContainer;

+ (instancetype)layoutManagerWithAttributedString:(NSAttributedString *)attributedString maxSize:(CGSize)size;

- (CGRect)boundsRect;

@end
