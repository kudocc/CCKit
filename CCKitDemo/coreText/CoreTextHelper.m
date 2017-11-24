//
//  CoreTextHelper.m
//  demo
//
//  Created by KudoCC on 16/6/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreTextHelper.h"
#import "NSAttributedString+CCKit.h"
#import "UIImage+CCKit.h"
#import "UIColor+CCKit.h"

@implementation CoreTextHelper

+ (NSAttributedString *)attributedStringFromContent:(NSString *)content {
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[\\w+.(jpeg|jpg|png)\\]" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *results = [regularExpression matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    NSMutableAttributedString *mAttrString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSUInteger location = 0;
    for (NSTextCheckingResult *result in results) {
        NSRange rangeBefore = NSMakeRange(location, result.range.location-location);
        if (rangeBefore.length > 0) {
            NSString *subString = [content substringWithRange:rangeBefore];
            NSMutableAttributedString *subAttrString = [[NSMutableAttributedString alloc] initWithString:subString];
            [mAttrString appendAttributedString:subAttrString];
        }
        location = result.range.location + result.range.length;
        
        // image found
        NSRange rangeImageName = NSMakeRange(result.range.location+1, result.range.length-2);
        NSString *imageName = [content substringWithRange:rangeImageName];
        UIImage *image = [UIImage imageNamed:imageName];
        image = [UIImage cc_resizeImage:image contentMode:UIViewContentModeScaleToFill size:CGSizeMake(50, 50)];
        if (image) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            NSAttributedString *attrAttach = [NSAttributedString attributedStringWithAttachment:attachment];
            [mAttrString appendAttributedString:attrAttach];
        }
    }
    if (location < content.length) {
        NSString *subString = [content substringFromIndex:location];
        NSMutableAttributedString *subAttrString = [[NSMutableAttributedString alloc] initWithString:subString];
        [mAttrString appendAttributedString:subAttrString];
    }
    
    [mAttrString cc_setColor:[UIColor blackColor]];
    [mAttrString cc_setFont:[UIFont systemFontOfSize:14]];
    [mAttrString cc_setLineSpacing:1];
//    [mAttrString cc_setSuperscript:1 range:NSMakeRange(mAttrString.length-3, 1)];
//    [mAttrString cc_setHyphenationFactor:0.99];
//    [mAttrString cc_setFirstLineHeadIndent:10];
    
    return [mAttrString copy];
}

@end
