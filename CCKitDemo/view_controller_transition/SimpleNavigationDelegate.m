//
//  SimpleNavigationDelegate.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "SimpleNavigationDelegate.h"
#import "CustomAnimator.h"

@interface SimpleNavigationDelegate ()

@property (nonatomic) AnimatorPush *animatorPush;
@property (nonatomic) AnimatorPop *animatorPop;

@end

@implementation SimpleNavigationDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _animatorPush = [AnimatorPush new];
        _animatorPop = [AnimatorPop new];
    }
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        return _animatorPush;
    } else {
        return _animatorPop;
    }
}

@end
