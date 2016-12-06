//
//  AnimationKeyboardViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/11/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AnimationKeyboardViewController.h"

static NSString *const kAnimationTriggerByKeyboard = @"kAnimationTriggerByKeyboard";
static NSString *const kAnimationCancelByKeyboard = @"kAnimationCancelByKeyboard";

@interface AnimationKeyboardViewController () <CAAnimationDelegate>

@property (nonatomic) CALayer *layerSnapshot;

@property (nonatomic) UITextField *textField;
@property (nonatomic) UITextField *textField1;

@property (nonatomic) UIWindow *window;

@end

@implementation AnimationKeyboardViewController


- (void)initView {
    self.enableTap = YES;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 84, ScreenWidth-30, 50.0)];
    _textField.layer.borderColor = [UIColor yellowColor].CGColor;
    _textField.layer.borderWidth = 1.0;
    [self.view addSubview:_textField];
    
    _layerSnapshot = [[CALayer alloc] init] ;
    UIImage *image = [UIImage imageNamed:@"conan1"];
    _layerSnapshot.frame = CGRectMake(0.0, 144.0, image.size.width, image.size.height);
    _layerSnapshot.contents = (__bridge id)image.CGImage ;
    [self.view.layer addSublayer:_layerSnapshot];
    
    [self showRightBarButtonItemWithName:@"show keyboard"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeVisibleNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@, %@", note.name, note);
        id obj = note.object;
        if ([obj isKindOfClass:[UIView class]]) {
            UIView *v = (UIView *)obj;
            [v logViewHierarchy];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeHiddenNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@, %@", note.name, note);
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeKeyNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@, %@", note.name, note);
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidResignKeyNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@, %@", note.name, note);
    }];
    */
    
    /*
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _window.windowLevel = UIWindowLevelAlert;
//    UIViewController *vc = [[UIViewController alloc] init];
    _window.backgroundColor = [UIColor redColor];
    [_window.layer addSublayer:_layerSnapshot];
//    _window.rootViewController = vc;
    [_window makeKeyAndVisible];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_textField becomeFirstResponder];
    });*/
    
//    NSDictionary *dict = @{UIKeyboardAnimationDurationUserInfoKey:@0.25};
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification object:nil userInfo:dict];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification object:nil userInfo:dict];
//    });
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    [_textField becomeFirstResponder];
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    [_textField resignFirstResponder];
}

#pragma mark - animation

- (CABasicAnimation *)positionAnimationFrom:(CGPoint)from to:(CGPoint)to duration:(CFTimeInterval)duration {
    CABasicAnimation *animationPos = [CABasicAnimation animationWithKeyPath:@"position"];
    animationPos.fromValue = [NSValue valueWithCGPoint:from];
    animationPos.toValue = [NSValue valueWithCGPoint:to];
    animationPos.fillMode = kCAFillModeForwards;
    animationPos.duration = duration;
    return animationPos;
}

- (CABasicAnimation *)boundsAnimationFrom:(CGRect)from to:(CGRect)to duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:from];
    animation.toValue = [NSValue valueWithCGRect:to];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = duration;
    return animation;
}

- (CABasicAnimation *)opacityAnimationFrom:(float)from to:(float)to duration:(CFTimeInterval)duration {
    CABasicAnimation *animationAlpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationAlpha.fromValue = @(from);
    animationAlpha.toValue = @(to);
    animationAlpha.duration = duration;
    return animationAlpha;
}

- (void)animationDidStart:(CAAnimation *)anim {
//    CGPoint pos = _layerSnapshot.presentationLayer.position;
//    CGRect bounds = _layerSnapshot.presentationLayer.bounds;
//    NSLog(@"%@, %@, pos:%@, bounds:%@", anim, NSStringFromSelector(_cmd), NSStringFromCGPoint(pos), NSStringFromCGRect(bounds));
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    NSLog(@"%@, %@", anim, NSStringFromSelector(_cmd));
}

#pragma mark - keyboard

- (CGPoint)convertOriginPoint:(CGPoint)origin toPositionOfLayer:(CALayer *)layer {
    return CGPointMake(origin.x+layer.bounds.size.width*layer.anchorPoint.x, origin.y+layer.bounds.size.height*layer.anchorPoint.y);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"************%@, duration:%@, frame:%@", NSStringFromSelector(_cmd), @(duration), NSStringFromCGRect(keyboardFrame));
    
    CGPoint posTo = CGPointMake(ScreenWidth-_layerSnapshot.bounds.size.width, _layerSnapshot.frame.origin.y);
    posTo = [self convertOriginPoint:posTo toPositionOfLayer:_layerSnapshot];
    CGPoint posFrom = CGPointMake(0.0, _layerSnapshot.frame.origin.y);
    posFrom = [self convertOriginPoint:posFrom toPositionOfLayer:_layerSnapshot];
    
    // 覆盖动画
    if (_layerSnapshot.animationKeys.count > 0 &&
        [_layerSnapshot.animationKeys indexOfObject:@"position"] != NSNotFound) {
        if (_layerSnapshot.presentationLayer) {
            posFrom = _layerSnapshot.presentationLayer.position;
            NSLog(@"presention layer exist, %@", NSStringFromCGPoint(_layerSnapshot.presentationLayer.position));
        }
    }
    
    CABasicAnimation *animationPos = [self positionAnimationFrom:posFrom to:posTo duration:duration];
    animationPos.delegate = self;
    [_layerSnapshot addAnimation:animationPos forKey:@"position"];
    NSLog(@"pos:%@, pos to:%@", NSStringFromCGPoint(posFrom), NSStringFromCGPoint(posTo));
    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    _layerSnapshot.position = posTo;
//    [CATransaction commit];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGPoint pos = CGPointMake(0, ScreenHeight-_layerSnapshot.bounds.size.height);
    pos = [self convertOriginPoint:pos toPositionOfLayer:_layerSnapshot];
    _layerSnapshot.position = pos;
}

@end
