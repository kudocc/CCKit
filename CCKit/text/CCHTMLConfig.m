//
//  CCHTMLConfig.m
//  demo
//
//  Created by KudoCC on 16/6/13.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCHTMLConfig.h"

@implementation CCHTMLConfig

+ (CCHTMLConfig *)defaultConfig {
    return [[CCHTMLConfig alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _defaultFontSize = 14.0;
        _defaultTextColor = [UIColor blackColor];
        _fontName = @"Helvetica";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) obj = [[self.class alloc] init];
    obj.defaultFontSize = self.defaultFontSize;
    obj.defaultTextColor = [self.defaultTextColor copy];
    obj.fontName = [self.fontName copy];
    obj.colorHyperlinkNormal = [self.colorHyperlinkNormal copy];
    obj.colorHyperlinkHighlighted = [self.colorHyperlinkHighlighted copy];
    obj.bgcolorHyperlinkNormal = [self.bgcolorHyperlinkNormal copy];
    obj.bgcolorHyperlinkHighlighted = [self.bgcolorHyperlinkHighlighted copy];
    obj.hyperlinkBlock = [self.hyperlinkBlock copy];
    return obj;
}

@end
