//
//  CCHTMLParser.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCHTMLParser.h"
#import "CCStack.h"
#import "NSString+CCKit.h"
#import "NSAttributedString+CCKit.h"
#import "UIColor+CCKit.h"
#import "UIFont+CCKit.h"

//https://en.wikipedia.org/wiki/HTML_attribute

#define RangeLength(startPos, endPos) (endPos-startPos+1)

NSString *const CCHTMLParseErrorDomain = @"CCHTMLParseErrorDomain";

NSString *const CCHTMLTagNameHTML = @"html";
NSString *const CCHTMLTagNameBody = @"body";
// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a
NSString *const CCHTMLTagNameA = @"a";
// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/font
NSString *const CCHTMLTagNameFont = @"font";
// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/p
NSString *const CCHTMLTagNameP = @"p";
NSString *const CCHTMLTagNameImg = @"img";
NSString *const CCHTMLTagNameBr = @"br";
NSString *const CCHTMLTagNameB = @"b";
NSString *const CCHTMLTagNameI = @"i";
NSString *const CCHTMLTagNameU = @"u";
NSString *const CCHTMLTagNameS = @"s";

// TODO: unsupported (but we will) tags
/// tag <sup></sup> 上标
NSString *const CCHTMLTagNameSup = @"sup";
/// tag <sub></sub> 下标
NSString *const CCHTMLTagNameSub = @"sub";

NSString *const CCHTMLTagAttributeNameHref = @"href";
NSString *const CCHTMLTagAttributeNameSource = @"src";
NSString *const CCHTMLTagAttributeNameColor = @"color";
NSString *const CCHTMLTagAttributeNameBgColor = @"bgcolor";
NSString *const CCHTMLTagAttributeNameSize = @"size";
NSString *const CCHTMLTagAttributeNameWidth = @"width";
NSString *const CCHTMLTagAttributeNameHeight = @"height";
NSString *const CCHTMLTagAttributeNameBorder = @"border";
NSString *const CCHTMLTagAttributeNameAlign = @"align";

static NSDictionary *htmlSpecialCharacterMap;

@interface CCHTMLTag ()

@property (nonatomic) CCHTMLConfig *config;
/// 直接包含此tag的CCHTMLTag对象
@property (nonatomic) CCHTMLTag *containerTag;
@property (nonatomic) NSString *tagName;
@property (nonatomic) NSMutableDictionary<NSString *, id> *attributes;
@property (nonatomic) NSMutableArray<CCHTMLTag *> *subTagItems;
@property (nonatomic) NSRange effectRange;
@property (nonatomic) NSString *placeholderBegin;
@property (nonatomic) NSString *placeholderEnd;
@property (nonatomic) BOOL emptyTag;
@property (nonatomic) NSArray<NSString *> *supportedAttributes;

- (void)addAttribute:(NSString *)attribute value:(NSString *)value;

@end

@implementation CCHTMLTag

+ (CCHTMLTag *)tagItemWithTagName:(NSString *)tagName {
    static NSDictionary *tagNameToPlaceholder = nil;
    static NSDictionary *tagNameToAttributes = nil;
    static NSArray *availableTagNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagNameToPlaceholder = @{CCHTMLTagNameP:@[@"\n", @"\n"],
                                 CCHTMLTagNameImg:@[CCAttachmentCharacter, @""],
                                 CCHTMLTagNameBr:@[@"\n", @""]};
        
        tagNameToAttributes = @{CCHTMLTagNameHTML:@[],
                                CCHTMLTagNameBody:@[CCHTMLTagAttributeNameBgColor],
                                CCHTMLTagNameA:@[CCHTMLTagAttributeNameHref],
                                CCHTMLTagNameFont:@[CCHTMLTagAttributeNameColor, CCHTMLTagAttributeNameSize],
                                CCHTMLTagNameP:@[CCHTMLTagAttributeNameAlign],
                                CCHTMLTagNameImg:@[CCHTMLTagAttributeNameSource, CCHTMLTagAttributeNameWidth, CCHTMLTagAttributeNameHeight, CCHTMLTagAttributeNameBorder],
                                CCHTMLTagNameBr:@[]
                                };
        
        availableTagNames = @[CCHTMLTagNameHTML,
                              CCHTMLTagNameBody,
                              CCHTMLTagNameA,
                              CCHTMLTagNameFont,
                              CCHTMLTagNameP,
                              CCHTMLTagNameImg,
                              CCHTMLTagNameBr,
                              CCHTMLTagNameB,
                              CCHTMLTagNameI,
                              CCHTMLTagNameU,
                              CCHTMLTagNameS];
    });
    
//    if ([availableTagNames containsObject:tagName]) {
        CCHTMLTag *item = [[CCHTMLTag alloc] init];
        item.tagName = tagName;
        item.supportedAttributes = tagNameToAttributes[tagName];
        NSArray *placeholders = tagNameToPlaceholder[tagName];
        if (placeholders) {
            item.placeholderBegin = placeholders[0];
            item.placeholderEnd = placeholders[1];
        }
        return item;
//    }
//    NSLog(@"warning: we don't support the tag name:%@", tagName);
//    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        _attributes = [NSMutableDictionary dictionary];
        _subTagItems = [NSMutableArray array];
    }
    return self;
}

- (void)addAttribute:(NSString *)attribute value:(NSString *)value {
    _attributes[attribute] = value;
}

- (void)debugTagItem {
    NSLog(@"tag name:%@", _tagName);
    NSLog(@"attribute:%@", _attributes);
    NSLog(@"effect range:%@", NSStringFromRange(_effectRange));
    for (CCHTMLTag *item in _subTagItems) {
        [item debugTagItem];
    }
}

- (NSTextAlignment)textAlignmentOfString:(NSString *)strAlignment {
    NSTextAlignment alignment = NSTextAlignmentNatural;
    if ([strAlignment isEqualToString:@"left"]) {
        alignment = NSTextAlignmentLeft;
    } else if ([strAlignment isEqualToString:@"right"]) {
        alignment = NSTextAlignmentRight;
    } else if ([strAlignment isEqualToString:@"center"]) {
        alignment = NSTextAlignmentCenter;
    } else if ([strAlignment isEqualToString:@"justify"]) {
        alignment = NSTextAlignmentJustified;
    }
    return alignment;
}

- (void)applyAttributeOnMutableAttributedString:(NSMutableAttributedString *)wholeString {
    [_attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (![_supportedAttributes containsObject:key]) return;
        if ([key isEqualToString:CCHTMLTagAttributeNameColor]) {
            UIColor *color = [UIColor cc_opaqueColorWithHexString:obj];
            if (color) {
                [wholeString cc_setColor:color range:self.effectRange];
            }
        } else if ([key isEqualToString:CCHTMLTagAttributeNameBgColor]) {
            UIColor *color = [UIColor cc_opaqueColorWithHexString:obj];
            if (color) {
                [wholeString cc_setBgColor:color range:self.effectRange];
            }
        }
    }];
    
    // apply item attribute
    if ([_tagName isEqualToString:CCHTMLTagNameA]) {
        [wholeString cc_setUnderlineStyle:NSUnderlineStyleSingle range:self.effectRange];
        [wholeString cc_setUnderlineColor:[UIColor blueColor] range:self.effectRange];
        if (_config.colorHyperlinkNormal) {
            [wholeString cc_setColor:_config.colorHyperlinkNormal range:self.effectRange];
        }
        if (_config.bgcolorHyperlinkNormal) {
            [wholeString cc_setBgColor:_config.bgcolorHyperlinkNormal range:self.effectRange];
        }
        // href
        __weak typeof(self) wself = self;
        NSString *href = _attributes[CCHTMLTagAttributeNameHref];
        [wholeString cc_setHighlightedColor:_config.colorHyperlinkHighlighted
                                    bgColor:_config.bgcolorHyperlinkHighlighted
                                      range:self.effectRange tapAction:^(NSRange range) {
            if (wself.config.hyperlinkBlock) {
                wself.config.hyperlinkBlock(href);
            }
        }];
    } else if ([_tagName isEqualToString:CCHTMLTagNameFont]) {
        // size
        NSString *fontSize = _attributes[CCHTMLTagAttributeNameSize];
        if (fontSize) {
            UIFont *font = [wholeString cc_fontAtIndex:self.effectRange.location];
            UIFontDescriptor *descriptor = [font fontDescriptor];
            font = [UIFont fontWithDescriptor:descriptor size:[fontSize doubleValue]];
            if (font) {
                [wholeString cc_setFont:font range:self.effectRange];
            }
        }
    } else if ([_tagName isEqualToString:CCHTMLTagNameP]) {
        NSString *strAlignment = _attributes[CCHTMLTagAttributeNameAlign];
        if (strAlignment.length > 4) {
            [wholeString cc_setAlignment:[self textAlignmentOfString:strAlignment] range:self.effectRange];
        }
    } else if ([_tagName isEqualToString:CCHTMLTagNameImg]) {
        // src, width, height
        NSString *src = _attributes[CCHTMLTagAttributeNameSource];
        UIImage *image = [UIImage imageNamed:src];
        NSString *strWidth = _attributes[CCHTMLTagAttributeNameWidth];
        NSString *strHeight = _attributes[CCHTMLTagAttributeNameHeight];
        if (image && strWidth && strHeight) {
            UIFont *font = nil;
            if (self.effectRange.location > 0) {
                font = [wholeString cc_fontAtIndex:self.effectRange.location-1];
            }
            if (!font && (self.effectRange.location + self.effectRange.length) < wholeString.length) {
                font = [wholeString cc_fontAtIndex:self.effectRange.location + self.effectRange.length];
            }
            if (!font) {
                font = [wholeString cc_fontAtIndex:self.effectRange.location];
            }
            NSRange range = self.effectRange;
            if (self.effectRange.length > CCAttachmentCharacter.length) {
                range = NSMakeRange(self.effectRange.location, CCAttachmentCharacter.length);
            }
            [wholeString cc_setAttachmentWithContent:image
                                         contentMode:UIViewContentModeScaleAspectFill
                                         contentSize:CGSizeMake([strWidth integerValue], [strHeight integerValue])
                                         alignToFont:font
                                  attachmentPosition:CCTextAttachmentPositionBottom
                                               range:range];
        }
    } else if ([_tagName isEqualToString:CCHTMLTagNameB]) {
        // if its ancestors is a <i>, use Bold-Italic
        BOOL hasItalic = NO;
        CCHTMLTag *ancestor = self.containerTag;
        while (ancestor) {
            if ([ancestor.tagName isEqualToString:CCHTMLTagNameI]) {
                hasItalic = YES;
                break;
            }
            ancestor = ancestor.containerTag;
        }
        UIFont *font = [wholeString cc_fontAtIndex:self.effectRange.location];
        if (hasItalic) {
            font = [font cc_boldItalicFont];
        } else {
            font = [font cc_boldFont];
        }
        if (font) {
            [wholeString cc_setFont:font range:self.effectRange];
        }
    } else if ([_tagName isEqualToString:CCHTMLTagNameI]) {
        // if its ancestors is a <b>, use Bold-Italic
        BOOL hasBold = NO;
        CCHTMLTag *ancestor = self.containerTag;
        while (ancestor) {
            if ([ancestor.tagName isEqualToString:CCHTMLTagNameI]) {
                hasBold = YES;
                break;
            }
            ancestor = ancestor.containerTag;
        }
        UIFont *font = [wholeString cc_fontAtIndex:self.effectRange.location];
        if (hasBold) {
            font = [font cc_boldItalicFont];
        } else {
            font = [font cc_italicFont];
        }
        if (font) {
            [wholeString cc_setFont:font range:self.effectRange];
        }
    } else if ([_tagName isEqualToString:CCHTMLTagNameU]) {
        [wholeString cc_setUnderlineStyle:NSUnderlineStyleSingle range:self.effectRange];
    } else if ([_tagName isEqualToString:CCHTMLTagNameS]) {
        [wholeString cc_setStrikethroughStyle:NSUnderlineStyleSingle range:self.effectRange];
    }
    
    for (CCHTMLTag *item in _subTagItems) {
        [item applyAttributeOnMutableAttributedString:wholeString];
    }
}

@end

@interface CCHTMLParser ()
@property (nonatomic, readwrite) CCHTMLConfig *config;
@end

@implementation CCHTMLParser {
    CCStack *_stack;
}

+ (CCHTMLParser *)parserWithDefaultConfig {
    return [self parserWithConfig:[CCHTMLConfig defaultConfig]];
}

+ (CCHTMLParser *)parserWithConfig:(CCHTMLConfig *)config {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // TODO: there are more......
        htmlSpecialCharacterMap = @{@"&quot;":@"\"",
                                    @"&nbsp;":@" ",
                                    @"&lt;":@"<",
                                    @"&gt;":@">",
                                    @"&amp;":@"&"};
    });
    CCHTMLParser *parser = [[CCHTMLParser alloc] initWithConfig:config];
    return parser;
}

- (NSAttributedString *)attributedString {
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:self.mutableString];
    NSString *fontName = _config.fontName;
    UIFont *font = [UIFont fontWithName:fontName size:_config.defaultFontSize];
    [mutableAttrString cc_setFont:font];
    [mutableAttrString cc_setColor:_config.defaultTextColor];
    [_rootTag applyAttributeOnMutableAttributedString:mutableAttrString];
    return mutableAttrString;
}

- (id)initWithConfig:(CCHTMLConfig *)config {
    self = [super init];
    if (self) {
        _config = [config copy];
    }
    return self;
}

- (void)appendString:(NSString *)string combineWhitespaceToMutableString:(NSMutableString *)mutableString {
    // 换行符后不要whitespace，whitespace后不要whitespace，mutableString加入的第一个字符不能是whitespace
    if ([mutableString length] > 0) {
        unichar c = [mutableString characterAtIndex:mutableString.length-1];
        if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:c] ||
            [[NSCharacterSet newlineCharacterSet] characterIsMember:c]) {
            NSInteger reach = 0;
            [string cc_runUntilCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] fromLocation:0 reachLocation:&reach reachEnd:NULL];
            if (reach > 0) {
                string = [string substringFromIndex:reach];
            }
        }
    } else {
        NSInteger reach = 0;
        [string cc_runUntilCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] fromLocation:0 reachLocation:&reach reachEnd:NULL];
        if (reach > 0) {
            string = [string substringFromIndex:reach];
        }
    }
    if (string.length > 0) {
        [mutableString appendString:string];
    }
}

- (void)parseHTMLString:(NSString *)htmlString {
    _stack = [[CCStack alloc] init];
    _rootTag = nil;
    _mutableString = [[NSMutableString alloc] init];
    
    NSMutableArray *mutableRootArray = [NSMutableArray array];
    NSInteger searchPosition = 0;
    while (searchPosition < [htmlString length]) {
        BOOL isStartTag = NO;
        NSRange tagRange;
        NSError *error = nil;
        BOOL find = [self findTag:htmlString
                            range:NSMakeRange(searchPosition, [htmlString length]-1)
                findTagIsStartTag:&isStartTag
                            range:&tagRange
                            error:&error];
        if (error) {
            NSLog(@"parsed error:%@", [error localizedDescription]);
            return;
        }
        if (!find) {
            return;
        }
        NSString *tag = [htmlString substringWithRange:tagRange];
        if (isStartTag) {
            // 将开始标签之前的文本全部加入
            NSRange rangeText = NSMakeRange(searchPosition, RangeLength(searchPosition, tagRange.location-1));
            NSString *text = [htmlString substringWithRange:rangeText];
            searchPosition = tagRange.location + tagRange.length;
            
            CCHTMLTag *tagItem = [self constructTagWithTagStartString:tag];
            if (!tagItem) {
                break;
            }
            
            text = [self replaceHTMLSpecialCharacterAndTrimWhiltespaceNewlineCharater:text];
            [self appendString:text combineWhitespaceToMutableString:_mutableString];
            
            tagItem.config = self.config;
            tagItem.effectRange = NSMakeRange([_mutableString length], 0);
            if (tagItem.placeholderBegin) {
                [_mutableString appendString:tagItem.placeholderBegin];
            }
            
            CCHTMLTag *parentTag = [_stack top];
            if (parentTag) {
                tagItem.containerTag = parentTag;
                [parentTag.subTagItems addObject:tagItem];
            } else {
                [mutableRootArray addObject:tagItem];
            }
            
            if (!tagItem.emptyTag) {
                [_stack push:tagItem];
            }
        } else {
            NSString *tagName = [self extractEndTagName:tag];
            if ([tagName length] == 0) {
                break;
            }
            
            CCHTMLTag *top = [_stack top];
            if (!top || ![top.tagName isEqualToString:tagName]) {
                break;
            }
            [_stack pop];
            
            NSRange rangeText = NSMakeRange(searchPosition, RangeLength(searchPosition, tagRange.location-1));
            NSString *text = [htmlString substringWithRange:rangeText];
            text = [self replaceHTMLSpecialCharacterAndTrimWhiltespaceNewlineCharater:text];
            [self appendString:text combineWhitespaceToMutableString:_mutableString];
            if (top.placeholderEnd) {
                [_mutableString appendString:top.placeholderEnd];
            }
            top.effectRange = NSMakeRange(top.effectRange.location, RangeLength(top.effectRange.location, [_mutableString length]-1));
            searchPosition = tagRange.location + tagRange.length;
        }
    }
    
    if (![_stack isEmpty]) {
        NSLog(@"error, tag stack is not empty after parse");
        _mutableString = nil;
        [_stack popAll];
    } else {
        if (mutableRootArray.count > 1) {
            _rootTag = [[CCHTMLTag alloc] init];
            _rootTag.subTagItems = [mutableRootArray copy];
            _rootTag.tagName = @"root";
            _rootTag.effectRange = NSMakeRange(0, _mutableString.length);
            for (CCHTMLTag *tag in mutableRootArray) {
                tag.containerTag = _rootTag;
            }
        } else {
            _rootTag = mutableRootArray.firstObject;
        }
    }
}

- (NSString *)replaceHTMLSpecialCharacterAndTrimWhiltespaceNewlineCharater:(NSString *)string {
    // replace '\r' '\n' with space
    NSArray *array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    string = [array componentsJoinedByString:@" "];
    
    // compose two or more whitespace into one
    NSInteger i = 0;
    NSMutableString *mutableString = [NSMutableString string];
    NSCharacterSet *whitespaceCharSet = [NSCharacterSet whitespaceCharacterSet];
    while (i < [string length]) {
        unichar c = [string characterAtIndex:i];
        if ([whitespaceCharSet characterIsMember:c]) {
            NSInteger reachLocation = 0;
            [string cc_runUntilCharacterSet:[whitespaceCharSet invertedSet] fromLocation:i reachLocation:&reachLocation reachEnd:NULL];
            [mutableString appendString:@" "];
            i = reachLocation;
        } else {
            [mutableString appendFormat:@"%C", c];
            ++i;
        }
    }
    string = [mutableString copy];
    
    // replace HTML special character
    __block NSString *str = string;
    [htmlSpecialCharacterMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSRange range = [str rangeOfString:key];
        if (range.location != NSNotFound) {
            str = [str stringByReplacingOccurrencesOfString:key withString:value];
        }
    }];
    
    return str;
}

// 1.judge if it is a empty tag
// 2.find tag name
// 3.find attibutes
- (CCHTMLTag *)constructTagWithTagStartString:(NSString *)tagString {
    BOOL emptyTag = NO;
    NSString *tagName = nil;
    
    // trim '<' and '>'
    tagString = [tagString substringWithRange:NSMakeRange(1, [tagString length]-2)];
    
    // assume: 如果是empty tag，/ 符号紧挨着尖括号 <br />，这样是非法的<br / >
    unichar lastChar = [tagString characterAtIndex:[tagString length]-1];
    if (lastChar == '/') {
        emptyTag = YES;
        tagString = [tagString substringToIndex:[tagString length]-1];
    }
    
    NSInteger i = 0;
    [tagString cc_runUntilNoneSpaceFromLocation:0 noneSpaceLocation:&i reachEnd:NULL];
    // 找到tag名称
    for (i = 0; i < [tagString length]; ++i) {
        unichar c = [tagString characterAtIndex:i];
        if (c == ' ' || i == [tagString length]-1) {
            if (c == ' ') {
                tagName = [tagString substringToIndex:i];
            } else {
                tagName = [tagString copy];
            }
            // 再向后找到第一个不为' '的字符停止
            NSInteger pos = i+1;
            BOOL end = NO;
            [tagString cc_runUntilNoneSpaceFromLocation:i+1 noneSpaceLocation:&pos reachEnd:&end];
            if (!end) {
                tagString = [tagString substringFromIndex:pos];
            } else {
                tagString = @"";
            }
            break;
        }
    }
    if ([tagName length] == 0) {
        // we didn't find a tag name
        return nil;
    }
    
    CCHTMLTag *tagItem = [CCHTMLTag tagItemWithTagName:tagName];
    if (!tagItem) {
        return nil;
    }
    tagItem.emptyTag = emptyTag;
    if (emptyTag) {
        return tagItem;
    }
    
    // 找到属性，属性可以使用双引号或者单引号来引用，如果使用单引号引用，其内部可以使用双引号；反之亦然
    while ([tagString length] > 0) {
        unichar attributeValueQuotationMark = '=';
        NSString *attributeName = nil;
        NSInteger attributeValueLocation = 0;
        NSString *attributeValue = nil;
        NSInteger i = 0;
        while (i < [tagString length]) {
            unichar c = [tagString characterAtIndex:i];
            if (c == '=') {
                // we find a attributeName
                attributeName = [tagString substringToIndex:i];
                attributeName = [attributeName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([attributeName length] == 0) {
                    // error, attribute name can't be a empty string
                    return nil;
                }
                // 再向后找到第一个不为' '的字符停止
                NSInteger pos = i+1;
                BOOL end = NO;
                [tagString cc_runUntilNoneSpaceFromLocation:i+1 noneSpaceLocation:&pos reachEnd:&end];
                if (end) {
                    // error，'=' is the end char, no attribute value
                    return nil;
                }
                attributeValueQuotationMark = [tagString characterAtIndex:pos];
                if (attributeValueQuotationMark != '\'' &&
                    attributeValueQuotationMark != '\"') {
                    // error, quotation mark must be ' or "
                    return nil;
                }
                i = pos + 1;
                attributeValueLocation = pos + 1;
            } else if (c == attributeValueQuotationMark) {
                // we can get the attribute value here
                NSRange range = NSMakeRange(attributeValueLocation, RangeLength(attributeValueLocation, i-1));
                attributeValue = [tagString substringWithRange:range];
                if ([attributeValue length] == 0) {
                    // error, attribute value should be empty
                    return nil;
                }
                // add attribute
                [tagItem addAttribute:attributeName value:attributeValue];
                break;
            } else {
                ++i;
            }
        }
        
        [tagString cc_runUntilNoneSpaceFromLocation:i+1 noneSpaceLocation:&i reachEnd:NULL];
        if (i < [tagString length]) {
            tagString = [tagString substringFromIndex:i];
        } else {
            break;
        }
        // let's find the next attribute
    }
    
    return tagItem;
}

/// tagString is formatted as </tagName>
- (NSString *)extractEndTagName:(NSString *)tagString {
    NSRange range = NSMakeRange(2, [tagString length] - 3);
    if (range.length > 0) {
        NSString *tagName = [tagString substringWithRange:range];
        tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return tagName;
    }
    return nil;
}

// if find a tag, return YES
- (BOOL)findTag:(NSString *)htmlString range:(NSRange)range findTagIsStartTag:(BOOL *)startTag range:(NSRange *)tagRange error:(NSError **)error {
    BOOL findLeft = NO;
    BOOL findRight = NO;
    NSInteger tagStart = 0;
    for (NSInteger i = range.location; i < range.location + range.length; ++i) {
        unichar c = [htmlString characterAtIndex:i];
        if (c == '<') {
            if (findLeft) {
                *error = [NSError errorWithDomain:CCHTMLParseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"two '<' found before find a '>'"}];
                return NO;
            }
            findLeft = YES;
            
            // 标签的结束符号'/'就在'<'之后
            if (i+1 < range.location + range.length) {
                unichar after = [htmlString characterAtIndex:i+1];
                if (after == '/') {
                    *startTag = NO;
                } else {
                    *startTag = YES;
                }
            }
            
            tagStart = i;
        } else if (c == '>') {
            findRight = YES;
            if (!findLeft) {
                *error = [NSError errorWithDomain:CCHTMLParseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"no '<' found before find a '>'"}];
                return NO;
            }
            NSInteger length = RangeLength(tagStart, i);
            if (length <= 2) {
                *error = [NSError errorWithDomain:CCHTMLParseErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"just find a <>"}];
                return NO;
            }
            *tagRange = NSMakeRange(tagStart, length);
            return YES;
        }
    }
    return NO;
}

@end
