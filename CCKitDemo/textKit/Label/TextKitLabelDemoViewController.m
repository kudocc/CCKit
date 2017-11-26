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

// 测试发现
// numberOfLines = 1时，设置很长的文本
// preferredMaxLayoutWidth 固定很小，设置很长的文本，观察高度变化, 高度会增长，但是超过一定数值就UILabe中内容就是空，至少3000多是显示的

@interface TextKitLabelDemoViewController () <MDLLabelDelegate>

@property (nonatomic) NSMutableAttributedString *mString;
@property (nonatomic) UILabel *uilabel;
@property (nonatomic) MDLLabel *label;
@property (nonatomic) YYLabel *yyLabel;

@end

@implementation TextKitLabelDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *str = @"02345678901234\n567890123456789012345678901234567890123456789001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345";
    NSString *str = @"Hello everyone, this label is enhancement of UILabe. It can also detect url and email. For example: This link is https://www.baidu.com, try to email me at rui.yuan@musical.ly. Join two http://www.google.comhttps://www.github.com";
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
//        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
//        UIImage *image = [UIImage imageNamed:@"avatar_ori"];
//        imageAttachment.image = image;
//        imageAttachment.bounds = CGRectMake(0, [UIFont systemFontOfSize:14].descender, 50, 50);
//        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
//        [mAttr insertAttributedString:attachment atIndex:1];
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
    
    
    
    // MDLLabel
    self.label.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width * 0.675 - 20;
    self.label.attributedText = mAttr;
    self.label.numberOfLines = 0;
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
}

#pragma mark - MDLLabelDelegate

- (void)label:(MDLLabel *)label didTapHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange {
    NSLog(@"%@, range:%@", NSStringFromSelector(_cmd), [label.text substringWithRange:characterRange]);
}

- (void)label:(MDLLabel *)label didLongPressHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange {
    NSLog(@"%@, range:%@", NSStringFromSelector(_cmd), [label.text substringWithRange:characterRange]);
}

@end
