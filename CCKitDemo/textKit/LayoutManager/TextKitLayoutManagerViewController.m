//
//  TextKitLayoutManagerViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/16.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKitLayoutManagerViewController.h"
#import "TextKitView.h"
#import "NSAttributedString+CCKit.h"
#import "MDLMessageTextStorage.h"
#import "MDLLayoutManagerWrapper.h"
#import "MDLLabel.h"


@interface TextKitLayoutManagerViewController ()

@property (nonatomic) NSMutableAttributedString *mString;
@property (nonatomic) TextKitView *textView;
@property (nonatomic) MDLLabel *label;

@end

@implementation TextKitLayoutManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] initWithString:@"abc"];
    [m cc_setFont:[UIFont systemFontOfSize:11]];
    [m cc_setFont:[UIFont systemFontOfSize:12] range:NSMakeRange(1, 2)];
    [m cc_setColor:[UIColor blackColor]];
    [m setHighlightedColor:[UIColor blackColor] bgColor:[UIColor redColor] range:NSMakeRange(0, 3) tapAction:^(NSRange range) {
        NSLog(@"do one");
    }];
    [m setHighlightedColor:[UIColor blackColor] bgColor:[UIColor redColor] range:NSMakeRange(1, 2) tapAction:^(NSRange range) {
        NSLog(@"do two");
    }];
    
    [m enumerateAttribute:MDLMessagetextHighlightedAttributeName inRange:NSMakeRange(0, m.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        NSLog(@"value:%@, range:%@", value, NSStringFromRange(range));
    }];
    
    [m enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, m.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        NSLog(@"value:%@, range:%@", value, NSStringFromRange(range));
    }];
    
    
    NSString *str = @"The release of iOS 7 brings a lot of new tools to the table for developers. One of these is TextKit. TextKit consists of a bunch of new classes in UIKit that, as the name suggests, somehow deal with text. Here, we will cover how TextKit came to be, what it’s all about, and — by means of a couple of examples — how developers can put it to great use.\n\
    But let’s have some perspective first: TextKit is probably the most significant recent addition to UIKit. iOS 7’s new interface replaces a lot of icons and bezels with plain-text buttons. Overall, text and text layout play a much more significant role in all visual aspects of the OS. It is perhaps no overstatement to say that iOS 7’s redesign is driven by text — text that is all handled by TextKit.\n\
    Reviewing the answers I got from Apple engineers regarding porting the Cocoa Text System to iOS in hindsight reveals quite a bit of background information. The reason for the delay and the reduction in functionality is simple: performance, performance, performance. Text layout can be an extremely expensive task — memory-wise, power-wise, and time-wise — especially on a mobile device. Apple had to opt for a simpler solution and to wait for more processing power to be able to at least partially support a fully fledged text layout engine.";
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:str];
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
//    UIImage *image = [UIImage imageNamed:@"avatar_ori"];
//    imageAttachment.image = image;
    imageAttachment.bounds = CGRectMake(0, [UIFont systemFontOfSize:14].descender, 50, 50);
    NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    [mAttr insertAttributedString:attachment atIndex:1];
    [mAttr cc_addAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor], NSBaselineOffsetAttributeName: @0} range:NSMakeRange(100, 30) overrideOldAttribute:YES];
    [mAttr cc_setColor:[UIColor blackColor]];
    [mAttr cc_setFont:[UIFont systemFontOfSize:14]];
    [mAttr cc_setLineSpacing:1];
    [mAttr setHighlightedColor:[UIColor blueColor] bgColor:[UIColor grayColor] range:NSMakeRange(10, 50) tapAction:^(NSRange range) {
        NSLog(@"tap");
    }];
    
//    UIImage *image = [UIImage imageNamed:@"avatar"];
//    NSAttributedString *imageAttachment = [NSAttributedString cc_attachmentStringWithContent:image contentMode:UIViewContentModeScaleToFill contentSize:image.size alignToFont:[UIFont systemFontOfSize:14] attachmentPosition:CCTextAttachmentPositionTop];
//    [mAttr insertAttributedString:imageAttachment atIndex:1];
    
    
    self.mString = mAttr;
    
    self.textView = [[TextKitView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-80)];
    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11, *)) {
        [self.textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    } else {
        [self.textView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [self.textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    }
    self.textView.attrText = mAttr;
    
    self.label = [MDLLabel new];
    [self.view addSubview:self.label];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.label.topAnchor constraintEqualToAnchor:self.textView.bottomAnchor].active = YES;
    [self.label.leadingAnchor constraintEqualToAnchor:self.textView.leadingAnchor].active = YES;
    self.label.preferredMaxLayoutWidth = self.view.bounds.size.width;
    self.label.attributedText = mAttr;
    
    UIView *v = [UIView new];
    v.frame = CGRectMake(0, 0, 100, 100);
    v.translatesAutoresizingMaskIntoConstraints = YES;
    v.backgroundColor = [UIColor whiteColor];
    [self.label addSubview:v];
    
    
    [self showRightBarButtonItemWithName:@"Modify text"];
    
    
    {
        NSString *str = @"1 www.baidu.com of iOS 7 brings a lot of new tools to the table for developers. One of these is TextKit. TextKit consists of a bunch of new classes in UIKit that, as the name suggests, somehow deal with text. Here, we will cover how TextKit came to be, what it’s all about, and\n\
        — by means of a couple of examples — how developers can put it to great use";
        NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:str];
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
        imageAttachment.bounds = CGRectMake(0, [UIFont systemFontOfSize:14].descender, 50, 50);
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:1];
        [mAttr cc_addAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor], NSBaselineOffsetAttributeName: @0} range:NSMakeRange(0, 6) overrideOldAttribute:YES];
        [mAttr cc_setColor:[UIColor blackColor]];
        [mAttr cc_setFont:[UIFont systemFontOfSize:14]];
        [mAttr cc_addAttributes:@{NSLinkAttributeName:@"www.baidu.com"} range:NSMakeRange(2, 13) overrideOldAttribute:YES];
        
        MDLLayoutManagerWrapper *layout = [MDLLayoutManagerWrapper layoutManagerWithAttributedString:mAttr maxSize:CGSizeMake(100, 10000)];
        NSLog(@"%@", NSStringFromCGRect([layout boundsRect]));
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:label];
        [label.topAnchor constraintEqualToAnchor:self.label.bottomAnchor].active = YES;
        [label.leadingAnchor constraintEqualToAnchor:self.label.leadingAnchor].active = YES;
        [label.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:1].active = YES;
        [label.heightAnchor constraintEqualToConstant:50].active = YES;
        label.text = mAttr.string;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        label.shadowColor = [UIColor greenColor];
        label.shadowOffset = CGSizeMake(10, 30);
    }
    
    
    
    {
        NSString *str = @"The release www.baidu.com of iOS 7 brings a lot of new tools to the table for developers. One of these is TextKit. TextKit consists of a bunch of new classes in UIKit that, as the name suggests, somehow deal with text. Here, we will cover how TextKit came to be, what it’s all about, and — by means of a couple of examples — how developers can put it to great use.\n\
        But let’s have some perspective first: TextKit is probably the most significant recent addition to UIKit. iOS 7’s new interface replaces a lot of icons and bezels with plain-text buttons. Overall, text and text layout play a much more significant role in all visual aspects of the OS. It is perhaps no overstatement to say that iOS 7’s redesign is driven by text — text that is all handled by TextKit.\n\
        Reviewing the answers I got from Apple engineers regarding porting the Cocoa Text System to iOS in hindsight reveals quite a bit of background information. The reason for the delay and the reduction in functionality is simple: performance, performance, performance. Text layout can be an extremely expensive task — memory-wise, power-wise, and time-wise — especially on a mobile device. Apple had to opt for a simpler solution and to wait for more processing power to be able to at least partially support a fully fledged text layout engine. My phonenumber is 15901977044 abchttp://www.baidu.com email:cangmuma@126.com homepage:http://www.baidu.com15901977044";
        NSLog(@"begin parse");
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink error:nil];
        [dataDetector enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            NSString *strRange = [str substringWithRange:result.range];
            NSString *type = nil;
            if (result.resultType == NSTextCheckingTypePhoneNumber) {
                type = @"PhoneNumber";
            } else {
                type = @"Link";
            }
            NSLog(@"%@, %@, %@", strRange, type, @(flags));
        }];
        NSLog(@"end parse");
    }
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    [self.mString deleteCharactersInRange:NSMakeRange(0, 1)];
    self.textView.attrText = self.mString;
    self.label.attributedText = self.mString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
