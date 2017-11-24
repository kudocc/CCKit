//
//  MDLMenuLabel.m
//  CCKitDemo
//
//  Created by kudocc on 2017/10/10.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "MDLMenuLabel.h"

@interface MDLMenuLabel ()

@property (nonatomic) UILongPressGestureRecognizer *longPressGR;

@end

@implementation MDLMenuLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit {
    self.userInteractionEnabled = YES;
    
    self.longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    [self addGestureRecognizer:self.longPressGR];
    
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIMenuControllerDidHideMenuNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(wself) sself = wself;
        sself.backgroundColor = [UIColor clearColor];
    }];
}

- (void)forceShowMenu {
    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
        return;
    }
    
    [self showMenu];
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)longGR {
    if (longGR.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    [self showMenu];
}

- (void)showMenu {
    [self becomeFirstResponder];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.bounds inView:self];
    [menu setMenuVisible:YES animated:YES];
    
    if (self.selectedBackgroundColor) {
        self.backgroundColor = self.selectedBackgroundColor;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:) && self.text.length > 0) {
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender {
    NSString *text = [self.text copy];
    [UIPasteboard generalPasteboard].string = text;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
