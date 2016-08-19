//
//  UIFont+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/13.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "UIFont+CCKit.h"

@implementation UIFont (CCKit)

- (UIFont *)cc_boldFont {
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits symbolicTraits = fontDescriptor.symbolicTraits;
    symbolicTraits |= UIFontDescriptorTraitBold;
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits];
    return [UIFont fontWithDescriptor:boldFontDescriptor size:self.pointSize];
}

- (UIFont *)cc_italicFont {
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits symbolicTraits = fontDescriptor.symbolicTraits;
    symbolicTraits |= UIFontDescriptorTraitItalic;
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits];
    return [UIFont fontWithDescriptor:boldFontDescriptor size:self.pointSize];
}

- (UIFont *)cc_boldItalicFont {
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits symbolicTraits = fontDescriptor.symbolicTraits;
    symbolicTraits |= UIFontDescriptorTraitItalic;
    symbolicTraits |= UIFontDescriptorTraitBold;
    UIFontDescriptor *boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits];
    return [UIFont fontWithDescriptor:boldFontDescriptor size:self.pointSize];
}

@end
