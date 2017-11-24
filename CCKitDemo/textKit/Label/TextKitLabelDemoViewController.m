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
    
    NSString *thumbnail = @"http://www.baidu.com";
    if ([thumbnail rangeOfString:@"https" options:NSAnchoredSearch|NSCaseInsensitiveSearch].location != NSNotFound ||
        [thumbnail rangeOfString:@"http" options:NSAnchoredSearch|NSCaseInsensitiveSearch].location != NSNotFound) {
        NSLog(@"aaa");
    }
    
    NSString *str = @"0234567890123456789\n0123456789012345678901234567890123456789001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345";
//    NSString *str = @"The release of iOS 7 brings a lot of new tools to the table for developers. One of these is TextKit. TextKit consists of a bunch of new classes in UIKit that, as the name suggests, somehow deal with text. Here, we will cover how TextKit came to be, what it’s all about, and — by means of a couple of examples — how developers can put it to great use. But let’s have some perspective first: TextKit is probably the most significant recent addition to UIKit. iOS 7’s new interface replaces a lot of icons and bezels with plain-text buttons. Overall, text and text layout play a much more significant role in all visual aspects of the OS.";
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:str];
    [mAttr cc_setColor:[UIColor blackColor]];
    [mAttr cc_addAttributes:@{NSForegroundColorAttributeName:[UIColor yellowColor] ,
                              NSBackgroundColorAttributeName:[UIColor redColor]/*, NSBaselineOffsetAttributeName: @0*/} range:NSMakeRange(20, 30) overrideOldAttribute:YES];
    [mAttr cc_setFont:[UIFont systemFontOfSize:20]];
    [mAttr cc_setLineSpacing:10];
    
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *image = [UIImage imageNamed:@"avatar_ori"];
    imageAttachment.image = image;
    imageAttachment.bounds = CGRectMake(0, [UIFont systemFontOfSize:14].descender, 50, 50);
    NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    [mAttr insertAttributedString:attachment atIndex:1];
    
    MDLHighlightAttributeValue *highlightValue = [MDLHighlightAttributeValue new];
    highlightValue.effectRange = NSMakeRange(30, 10);
    highlightValue.highlightTextColor = [UIColor blueColor];
    highlightValue.highlightBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [mAttr mdl_addHighlightAttributeValue:highlightValue range:highlightValue.effectRange];
    
    YYTextHighlight *hi = [YYTextHighlight highlightWithBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [hi setColor:[UIColor blueColor]];
    [mAttr setTextHighlight:hi range:NSMakeRange(30, 10)];
    
    self.mString = mAttr;
    
    self.label = [MDLLabel new];
    [self.view addSubview:self.label];
    self.label.delegate = self;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11, *)) {
        [self.label.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.label.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    } else {
        [self.label.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [self.label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    }
    [self.label.heightAnchor constraintLessThanOrEqualToConstant:200].active = YES;
    self.label.layer.borderColor = [UIColor redColor].CGColor;
    self.label.layer.borderWidth = 1;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label.topAnchor constraintEqualToAnchor:self.label.bottomAnchor].active = YES;
    [label.leadingAnchor constraintEqualToAnchor:self.label.leadingAnchor].active = YES;
    [label.heightAnchor constraintLessThanOrEqualToConstant:200].active = YES;
    label.layer.borderColor = [UIColor redColor].CGColor;
    label.layer.borderWidth = 1;
    
    
    YYLabel *yyLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:yyLabel];
    yyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [yyLabel.topAnchor constraintEqualToAnchor:label.bottomAnchor].active = YES;
    [yyLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = YES;
    [yyLabel.heightAnchor constraintLessThanOrEqualToConstant:200].active = YES;
    yyLabel.layer.borderColor = [UIColor redColor].CGColor;
    yyLabel.layer.borderWidth = 1;
    
    self.label.preferredMaxLayoutWidth = self.view.bounds.size.width/2;
    self.label.attributedText = mAttr;
    self.label.lineBreakMode = NSLineBreakByTruncatingTail;
//    self.label.numberOfLines = 0;
//    self.label.shadowOffset = CGSizeMake(20, 10);
//    self.label.shadowColor = [UIColor greenColor];
    
    
    label.preferredMaxLayoutWidth = self.label.preferredMaxLayoutWidth;
    label.attributedText = mAttr;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
//    label.numberOfLines = 0;
//    label.shadowOffset = CGSizeMake(20, 10);
//    label.shadowColor = [UIColor greenColor];
    
    yyLabel.preferredMaxLayoutWidth = self.label.preferredMaxLayoutWidth;
    yyLabel.attributedText = mAttr;
    yyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
    NSLog(@"%@, range:%@", NSStringFromSelector(_cmd), NSStringFromRange(characterRange));
}

- (void)label:(MDLLabel *)label didLongPressHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange {
    NSLog(@"%@, range:%@", NSStringFromSelector(_cmd), NSStringFromRange(characterRange));
}

@end
