//
//  TextKitConstructTableViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/14.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKit_ConstructViewController.h"
#import "TextKit1Storage2LayoutManagerViewController.h"
#import "TextKit1Storage2ContainerViewController.h"

#import "NSAttributedString+CCKit.h"

@interface TextKit_ConstructViewController ()

@property IBOutlet UITextView *textView;
@property IBOutlet UIView *container1;
@property IBOutlet UIView *container2;

@property (weak, nonatomic) UITextView *otherTextView;
@property (weak, nonatomic) UITextView *thirdTextView;

@property (nonatomic, strong) NSTextStorage *storage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;

@end

@implementation TextKit_ConstructViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.container1.backgroundColor = [UIColor blueColor];
    self.container2.backgroundColor = [UIColor greenColor];
    
    NSString *str = @"The release of iOS 7 brings a lot of new tools to the table for developers. One of these is TextKit. TextKit consists of a bunch of new classes in UIKit that, as the name suggests, somehow deal with text. Here, we will cover how TextKit came to be, what it’s all about, and — by means of a couple of examples — how developers can put it to great use.\n\
    But let’s have some perspective first: TextKit is probably the most significant recent addition to UIKit. iOS 7’s new interface replaces a lot of icons and bezels with plain-text buttons. Overall, text and text layout play a much more significant role in all visual aspects of the OS. It is perhaps no overstatement to say that iOS 7’s redesign is driven by text — text that is all handled by TextKit.\n\
    To give an idea of how big this change really is: in every version of iOS prior to 7, (almost) all text was handled by WebKit. That’s right: WebKit, the web browser engine. All UILabels, UITextFields, and UITextViews were using web views in the background in some way to lay out and render text. For the new interface style, they have all been reengineered to take advantage of TextKit.\n\
    Reviewing the answers I got from Apple engineers regarding porting the Cocoa Text System to iOS in hindsight reveals quite a bit of background information. The reason for the delay and the reduction in functionality is simple: performance, performance, performance. Text layout can be an extremely expensive task — memory-wise, power-wise, and time-wise — especially on a mobile device. Apple had to opt for a simpler solution and to wait for more processing power to be able to at least partially support a fully fledged text layout engine.";
    
    self.storage = self.textView.textStorage;
    [self.storage replaceCharactersInRange:NSMakeRange(0, 0) withString:str];
//    [self.storage cc_setFont:[UIFont systemFontOfSize:14]];
//    [self.storage cc_setColor:[UIColor redColor]];
    
    NSLayoutManager *otherLayoutManager = [NSLayoutManager new];
    [self.storage addLayoutManager:otherLayoutManager];
    
    NSTextContainer *c1 = [NSTextContainer new];
    c1.widthTracksTextView = YES;
    [otherLayoutManager addTextContainer:c1];
    self.layoutManager = otherLayoutManager;
    
    UITextView *textView1 = [[UITextView alloc] initWithFrame:self.container1.bounds textContainer:c1];
    textView1.translatesAutoresizingMaskIntoConstraints = YES;
    textView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.container1 addSubview:textView1];
    
    textView1.scrollEnabled = NO;
    
    NSTextContainer *c2 = [NSTextContainer new];
    c2.widthTracksTextView = YES;
    [otherLayoutManager addTextContainer:c2];
    
    UITextView *textView2 = [[UITextView alloc] initWithFrame:self.container2.bounds textContainer:c2];
    textView2.translatesAutoresizingMaskIntoConstraints = YES;
    textView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.container2 addSubview:textView2];
    
    self.otherTextView = textView1;
    self.thirdTextView = textView2;
    
    self.storage = nil;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    label.translatesAutoresizingMaskIntoConstraints = YES;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.container2 addSubview:label];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"constraints : %@ ---00--- %@", self.container1.constraints, label.constraints);
    });
}

@end
