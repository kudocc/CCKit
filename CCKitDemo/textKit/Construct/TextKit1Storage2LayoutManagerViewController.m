//
//  TextKit1Storage2LayoutManagerViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/14.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKit1Storage2LayoutManagerViewController.h"
#import "NSAttributedString+CCKit.h"

@interface TextKit1Storage2LayoutManagerViewController () <UITextViewDelegate, NSLayoutManagerDelegate>

@property (nonatomic, strong) NSTextStorage *storage;

@end

@implementation TextKit1Storage2LayoutManagerViewController

- (void)initView {
    self.enableTap = NO;
    
    NSString *str = @"The release of iOS 7 brings a lot of new tools to the table for developers. One of these is TextKit. TextKit consists of a bunch of new classes in UIKit that, as the name suggests, somehow deal with text. Here, we will cover how TextKit came to be, what it’s all about, and — by means of a couple of examples — how developers can put it to great use.15901977044\n\
    But let’s have some perspective first: TextKit is probably the most significant recent addition to UIKit. iOS 7’s new interface replaces a lot of icons and bezels with plain-text buttons. Overall, text and text layout play a much more significant role in all visual aspects of the OS. It is perhaps no overstatement to say that iOS 7’s redesign is driven by text — text that is all handled by TextKit. Website:http://www.baidu.com\n\
    To give an idea of how big this change really is: in every version of iOS prior to 7, (almost) all text was handled by WebKit. That’s right: WebKit, the web browser engine. All UILabels, UITextFields, and UITextViews were using web views in the background in some way to lay out and render text. For the new interface style, they have all been reengineered to take advantage of TextKit. Email:cangmuma@126.comGoood\n\
    Reviewing the answers I got from Apple engineers regarding porting the Cocoa Text System to iOS in hindsight reveals quite a bit of background information. The reason for the delay and the reduction in functionality is simple: performance, performance, performance. Text layout can be an extremely expensive task — memory-wise, power-wise, and time-wise — especially on a mobile device. Apple had to opt for a simpler solution and to wait for more processing power to be able to at least partially support a fully fledged text layout engine.";
    
    
    
    NSTextStorage *storage = [[NSTextStorage alloc] initWithString:str];
    [storage cc_setFont:[UIFont systemFontOfSize:14]];
    
    self.storage = storage;
    
    NSLayoutManager *manager1 = [[NSLayoutManager alloc] init];
    [storage addLayoutManager:manager1];
    manager1.delegate = self;
    
    
    CGFloat width = self.view.bounds.size.width;
    NSTextContainer *container1 = [NSTextContainer new];
    container1.widthTracksTextView = YES;
    [manager1 addTextContainer:container1];
    
//    NSLayoutManager *manager2 = [[NSLayoutManager alloc] init];
//    [storage addLayoutManager:manager2];
//    manager2.delegate = self;
    
//    NSTextContainer *container2 = [NSTextContainer new];
//    [manager2 addTextContainer:container2];
    
    UITextView *textView1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 100, width, 200) textContainer:container1];
    [self.view addSubview:textView1];
    textView1.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
    textView1.editable = NO;
    textView1.selectable = YES;
    
//    UITextView *textView2 = [[UITextView alloc] initWithFrame:CGRectMake(0, 320, width, 200) textContainer:container2];
//    [self.view addSubview:textView2];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    [self.view endEditing:YES];
}

#pragma mark - NSLayoutManagerDelegate

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    if ([self.storage.layoutManagers indexOfObject:layoutManager] == 0) {
        return 0;
    } else {
        return 0;
    }
}

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex {
    if ([self.storage.layoutManagers indexOfObject:layoutManager] == 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSLog(@"%@", URL);
    return YES;
}

@end
