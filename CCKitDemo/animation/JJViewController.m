//
//  JJViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/14.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "JJViewController.h"
#import "NSObject+CCKit.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface CCScrollView : UIScrollView
@end


@interface CCView : UIView

@property (weak) UIView *weakView;
@property (weak) CCScrollView *scrollView;
@property (weak) UIPanGestureRecognizer *tap;

@end

@implementation CCView

- (void)processTouch:(NSSet *)touches {
    for (UITouch *t in touches) {
        [t setValue:_weakView forKey:@"view"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
    NSLog(@"CCView:%@", NSStringFromSelector(_cmd));
    
//    if (_scrollView.panGestureRecognizer.state == UIGestureRecognizerStatePossible ||
//        _scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
//    [self processTouch:touches];
//        [_scrollView.panGestureRecognizer touchesBegan:touches withEvent:event];
//    }
    
    [self processTouch:touches];
    [self processTouch:[event allTouches]];
    [_tap touchesBegan:touches withEvent:event];
    
//    for (UIGestureRecognizer *gr in _scrollView.gestureRecognizers) {
//        if (gr.state == UIGestureRecognizerStateEnded ||
//            gr.state == UIGestureRecognizerStatePossible) {
//            [gr touchesBegan:touches withEvent:event];
//        }
//    }
    
//    [_scrollView touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesMoved:touches withEvent:event];
    NSLog(@"CCView:%@", NSStringFromSelector(_cmd));
    
//    if (_scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged ||
//        _scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        [_scrollView.panGestureRecognizer touchesMoved:touches withEvent:event];
//    }
    
    [self processTouch:touches];
    [self processTouch:[event allTouches]];
    [_tap touchesMoved:touches withEvent:event];
    
//    for (UIGestureRecognizer *gr in _scrollView.gestureRecognizers) {
//        if (gr.state == UIGestureRecognizerStateBegan) {
//            [gr touchesMoved:touches withEvent:event];
//        }
//    }
    
//    [_scrollView touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
    NSLog(@"CCView:%@", NSStringFromSelector(_cmd));
    
//    if (_scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        [_scrollView.panGestureRecognizer touchesEnded:touches withEvent:event];
//    }
    
    [self processTouch:touches];
    [self processTouch:[event allTouches]];
    [_tap touchesEnded:touches withEvent:event];
    
//    for (UIGestureRecognizer *gr in _scrollView.gestureRecognizers) {
//        if (gr.state == UIGestureRecognizerStateChanged ||
//            gr.state == UIGestureRecognizerStateEnded) {
//            [gr touchesEnded:touches withEvent:event];
//        }
//    }
    
//    [_scrollView touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesCancelled:touches withEvent:event];
    NSLog(@"CCView:%@", NSStringFromSelector(_cmd));
    
//    if (_scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        [_scrollView.panGestureRecognizer touchesCancelled:touches withEvent:event];
//    }
    
    [self processTouch:touches];
    [self processTouch:[event allTouches]];
    [_tap touchesCancelled:touches withEvent:event];
    
//    for (UIGestureRecognizer *gr in _scrollView.gestureRecognizers) {
//        if (gr.state == UIGestureRecognizerStateChanged) {
//            [gr touchesCancelled:touches withEvent:event];
//        }
//    }
    
//    [_scrollView touchesCancelled:touches withEvent:event];
}

@end

@implementation CCScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:label];
        label.text = @"A very long long \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text \nlong long long long long text";
        label.numberOfLines = 0;
        
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        [self.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
        
        
        [self.class logMethodNames];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        NSLog(@"contentOffset change:%@", change[NSKeyValueChangeNewKey]);
    } else if ([keyPath isEqualToString:@"state"] && object == self.panGestureRecognizer) {
        NSNumber *v = change[NSKeyValueChangeNewKey];
        if ([v integerValue] == UIGestureRecognizerStateChanged) {
            NSLog(@"pan gesture state go to changed");
        } else if ([v integerValue] == UIGestureRecognizerStateEnded) {
            NSLog(@"pan gesture state go to end");
        }
        NSLog(@"contentOffset pan gesture state change:%@", v);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"CCScrollView:%@", NSStringFromSelector(_cmd));
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"CCScrollView:%@", NSStringFromSelector(_cmd));
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"CCScrollView:%@", NSStringFromSelector(_cmd));
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"CCScrollView:%@", NSStringFromSelector(_cmd));
}

@end

@interface JJViewController ()

@property CCView *ccView;
@property CCScrollView *ccScrollView;

@property UIPanGestureRecognizer *tapGR;

@end

@implementation JJViewController

- (void)initView {
    _ccScrollView = [[CCScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:_ccScrollView];
    _ccScrollView.backgroundColor = [UIColor greenColor];
    _ccScrollView.contentSize = CGSizeMake(_ccScrollView.width, _ccScrollView.height*2);
    
    [_ccScrollView logViewHierarchy];
    NSLog(@"%@", _ccScrollView.gestureRecognizers);
    
    _ccView = [[CCView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight/2)];
    _ccView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_ccView];
    _ccView.frame = _ccScrollView.frame;
    _ccView.alpha = 0.5;
    _ccView.scrollView = _ccScrollView;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 100, 200)];
    v.backgroundColor = [UIColor blackColor];
    [self.view addSubview:v];
    _tapGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapOn:)];
    [v addGestureRecognizer:_tapGR];
    _ccView.tap = _tapGR;
    _ccView.weakView = v;
}

- (void)tapOn:(UIPanGestureRecognizer *)tap {
    NSLog(@"%@, state:%@", NSStringFromSelector(_cmd), @(tap.state));
}

@end
