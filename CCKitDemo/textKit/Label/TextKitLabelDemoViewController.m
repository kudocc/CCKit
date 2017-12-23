//
//  TextKitLabelDemoViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/11/11.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKitLabelDemoViewController.h"
#import "NSAttributedString+CCKit.h"
#import "MDLLabel.h"
#import <YYLabel.h>
#import <NSAttributedString+YYText.h>
#import "UIImage+CCKit.h"

@interface MDLDataDetector : NSDataDetector
@end

@implementation MDLDataDetector

- (void)enumerateMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (NS_NOESCAPE ^)(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL *stop))block {
    [super enumerateMatchesInString:string options:options range:range usingBlock:block];
}

@end


@interface TextKitLabelDemoViewController () <MDLLabelDelegate>

@property (nonatomic) NSMutableAttributedString *mString;
@property (nonatomic) UILabel *uilabel;
@property (nonatomic) MDLLabel *label;
@property (nonatomic) YYLabel *yyLabel;

@property (nonatomic) NSString *str;

@end

@implementation TextKitLabelDemoViewController

- (UIImage *)imageWithLocalFileURL:(NSURL *)url {
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (imageSource) {
        CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
        NSDictionary *dictProperty = (__bridge_transfer id)property;
        NSLog(@"container property:%@", dictProperty);
        
        property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        dictProperty = (__bridge_transfer id)property;
        NSLog(@"image at index 0 property:%@", dictProperty);
        
        UIImageOrientation orientation = UIImageOrientationUp;
        int exifOrientation;
        CFTypeRef val = CFDictionaryGetValue(property, kCGImagePropertyOrientation);
        if (val) {
            CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
            orientation = [UIImage cc_exifOrientationToiOSOrientation:exifOrientation];
        }
        
        CFDictionaryRef gifDict = CFDictionaryGetValue(property, kCGImagePropertyGIFDictionary);
        CGFloat dur = 0.2;
        if (gifDict) {
            CFStringRef val = CFDictionaryGetValue(gifDict, kCGImagePropertyGIFDelayTime);
            NSString *delay = (__bridge NSString *)val;
            dur = [delay doubleValue];
        }
        
        size_t count = CGImageSourceGetCount(imageSource);
        NSLog(@"image count:%zu", count);
        dur = dur * count;
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (size_t i = 0; i < count; ++i) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:orientation];
                [mutableArray addObject:image];
                CGImageRelease(img);
            }
        }
        CFRelease(imageSource);
        
        UIImage *result = [UIImage animatedImageWithImages:[mutableArray copy] duration:dur];
        return result;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *str = @"02345678901234\n567890123456789012345678901234567890123456789001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345";
    NSString *str = @"Hello everyone, this label is enhancement of UILabel. It can also detect url and email. For example: This link is https://www.baidu.com, try to email me at rui.yuan@musical.ly. Join two http://www.google.comhttps://www.github.com";
//    NSString *str = @"👩‍👧‍👦🎒👖🎒🎒👔🎒🎒🎒🎒👔👩‍👧‍👦🎒🎒🎒👔👨‍👧‍👦🎒🎒🎒👔👨‍👧‍👦🎒🎒🎒🎒👨‍👦‍👦🎒🎒🎒🎒🎒🎒👔👨‍👧‍👦🐌🐌🙊🐌🐌🐌🙊🐌🙉🐌🐌🐌🐌🐷🐌🙉🐌🐌🐌🐌🐷🐌🙊🐌🐂🐁🐁🐄🐇🐇🐂🐇🐄🐁🐋🐁🐁🐄🐂🐂🦏🐁🐂🐁🐋🐁🐁🐂🐄🌗🎍🌗🌖🌖🎋🎋🌘🌗🌴🌗🌗";
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:str];
    [mAttr cc_setColor:[UIColor blackColor]];
    [mAttr cc_setFont:[UIFont systemFontOfSize:14]];
    [mAttr cc_addAttributes:@{NSForegroundColorAttributeName:[UIColor yellowColor] ,
                              NSBackgroundColorAttributeName:[UIColor redColor]/*, NSBaselineOffsetAttributeName: @0*/} range:NSMakeRange(20, 30) overrideOldAttribute:YES];
    
    {// paragraph
        [mAttr cc_setLineSpacing:1];
//        NSMutableParagraphStyle *pa = [[NSMutableParagraphStyle alloc] init];
//        pa.lineBreakMode = NSLineBreakByCharWrapping;
//        [mAttr cc_addAttributes:@{ NSParagraphStyleAttributeName : pa }];
    }
    

    {// attachment
        UIFont *font = [mAttr cc_font];
        UIImage *image = [UIImage imageNamed:@"avatar_ori"];
        MDLTextAttachment *imageAttachment = [MDLTextAttachment imageAttachmentWithImage:image size:CGSizeMake(50, 50) alignFont:font];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:1];
    }
    
    {// attachment
        UIFont *font = [mAttr cc_font];
        UIImage *image = [UIImage imageNamed:@"avatar_ori"];
        MDLTextAttachment *imageAttachment = [MDLTextAttachment imageAttachmentWithImage:image size:CGSizeMake(100, 100) alignFont:font];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:1];
    }
    
    {// gif attachment
        NSString *path = [[NSBundle mainBundle] pathForResource:@"image_source" ofType:@"gif"];
        NSURL *url = [NSURL fileURLWithPath:path];
        UIImage *image = [self imageWithLocalFileURL:url];
        UIFont *font = [mAttr cc_font];
        MDLTextAttachment *imageAttachment = [MDLTextAttachment imageAttachmentWithImage:image size:CGSizeMake(60, 80) alignFont:font];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:4];
    }
    
    self.mString = mAttr;
    
    self.label = [MDLLabel new];
    [self.view addSubview:self.label];
    self.label.delegate = self;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11, *)) {
        [self.label.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.label.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    } else {
        [self.label.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:64].active = YES;
        [self.label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    }
    [self.label.heightAnchor constraintLessThanOrEqualToConstant:500].active = YES;
    self.label.layer.borderColor = [UIColor redColor].CGColor;
    self.label.layer.borderWidth = 1;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label.topAnchor constraintEqualToAnchor:self.label.bottomAnchor].active = YES;
    [label.leadingAnchor constraintEqualToAnchor:self.label.leadingAnchor].active = YES;
    [label.heightAnchor constraintLessThanOrEqualToConstant:500].active = YES;
    label.layer.borderColor = [UIColor redColor].CGColor;
    label.layer.borderWidth = 1;
    
    
    YYLabel *yyLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:yyLabel];
    yyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [yyLabel.topAnchor constraintEqualToAnchor:label.bottomAnchor].active = YES;
    [yyLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = YES;
    [yyLabel.heightAnchor constraintLessThanOrEqualToConstant:500].active = YES;
    yyLabel.layer.borderColor = [UIColor redColor].CGColor;
    yyLabel.layer.borderWidth = 1;
    
    
    MDLDataDetector *detector = [[MDLDataDetector alloc] initWithTypes:UIDataDetectorTypeAll error:nil];
    
    // MDLLabel
    self.label.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width * 0.675 - 20;
    self.label.attributedText = mAttr;
    self.label.numberOfLines = 0;
    self.label.customDataDetector = detector;
    self.label.dataDetectorTypes = UIDataDetectorTypeAll;
    self.label.asyncDataDetector = YES;
    
    // UILabel
    label.preferredMaxLayoutWidth = self.label.preferredMaxLayoutWidth;
    label.text = mAttr.string;
    label.numberOfLines = 0;
//    label.shadowOffset = CGSizeMake(20, 10);
//    label.shadowColor = [UIColor greenColor];
    
    
    // YYLabel
    {
        YYTextHighlight *hi = [YYTextHighlight highlightWithBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [hi setColor:[UIColor blueColor]];
        [mAttr setTextHighlight:hi range:NSMakeRange(30, 10)];
    }
    
    yyLabel.preferredMaxLayoutWidth = self.label.preferredMaxLayoutWidth;
    yyLabel.attributedText = mAttr;
    yyLabel.numberOfLines = 0;
    
    self.uilabel = label;
    self.yyLabel = yyLabel;
    
    [self showRightBarButtonItemWithName:@"Modify text"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    [self.mString deleteCharactersInRange:NSMakeRange(0, 1)];
    self.uilabel.attributedText = self.mString;
    self.label.attributedText = self.mString;
    
    void *pp = (__bridge void *)self.str;
    long long l = (long long)&pp;
    NSLog(@"%p, %p, %lld", self.str, &(pp), l);
    self.str = [self.mString.string copy];
    void *pp1 = (__bridge void *)self.str;
    long long l1 = (long long)&pp1;
    NSLog(@"%p, %p, %lld", self.str, &(pp1), l1);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        void *pp1 = (__bridge void *)self.str;
        long long l1 = (long long)&pp1;
        NSLog(@"%p, %p, %lld", self.str, &(pp1), l1);
    });
}

#pragma mark - MDLLabelDelegate

- (void)label:(MDLLabel *)label didTapHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange {
    NSLog(@"%@, range:%@", NSStringFromSelector(_cmd), [label.text substringWithRange:characterRange]);
}

- (void)label:(MDLLabel *)label didLongPressHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange {
    NSLog(@"%@, range:%@", NSStringFromSelector(_cmd), [label.text substringWithRange:characterRange]);
}

@end
