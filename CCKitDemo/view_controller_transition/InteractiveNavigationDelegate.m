//
//  InteractiveNavigationDelegate.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "InteractiveNavigationDelegate.h"
#import "CustomNavigationChildViewController.h"
#import "CustomAnimator.h"

@interface InteractiveNavigationDelegate ()

@property (nonatomic) AnimatorPush *animatorPush;
@property (nonatomic) AnimatorPop *animatorPop;

@property (nonatomic) UIPercentDrivenInteractiveTransition *interactionController;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation InteractiveNavigationDelegate

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

- (void)dealloc {
    [_navigationController.view removeGestureRecognizer:_panGestureRecognizer];
}

- (instancetype)initWithNavigationController:(UINavigationController *)nav {
    self = [super init];
    if (self) {
        _animatorPush = [AnimatorPush new];
        _animatorPop = [AnimatorPop new];
        
        _navigationController = nav;
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGR:)];
        [_navigationController.view addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

- (void)panGR:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint location = [panGestureRecognizer locationInView:_navigationController.view];
    UIView *view = _navigationController.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (location.x >  CGRectGetMidX(view.bounds)) {
            _interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
            
            CustomNavigationChildViewController *vc = [[CustomNavigationChildViewController alloc] init];
            [_navigationController pushViewController:vc animated:YES];
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view];
        CGFloat d = fabs(translation.x / CGRectGetWidth(view.bounds));
        [_interactionController updateInteractiveTransition:d];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([panGestureRecognizer velocityInView:view].x < 0) {
            [_interactionController finishInteractiveTransition];
        } else {
            [_interactionController cancelInteractiveTransition];
        }
        self.interactionController = nil;
    }
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactionController;
}

@end
