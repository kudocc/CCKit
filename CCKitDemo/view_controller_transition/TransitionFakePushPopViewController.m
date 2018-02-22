//
//  TransitionFakePushPopViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2018/2/11.
//  Copyright © 2018年 KudoCC. All rights reserved.
//

#import "TransitionFakePushPopViewController.h"

@implementation FakePresentAnimator

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect containerFrame = container.frame;
    CGRect toViewStartFrame = [transitionContext initialFrameForViewController:toVC];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toVC];
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromVC];

    
    UILabel *tagFromLabel = [[UILabel alloc] init];
    tagFromLabel.text = @"FROM";
    tagFromLabel.font = [UIFont systemFontOfSize:18];
    tagFromLabel.textColor = [UIColor blackColor];
    tagFromLabel.frame = CGRectMake(0, 0, 200, 100);
    [fromView addSubview:tagFromLabel];
    UILabel *tagToLabel = [[UILabel alloc] init];
    tagToLabel.text = @"TO";
    tagToLabel.font = [UIFont systemFontOfSize:18];
    tagToLabel.textColor = [UIColor blackColor];
    tagToLabel.frame = CGRectMake(0, 0, 200, 100);
    [toView addSubview:tagToLabel];
    
    
    
    if (fromView.superview == container) {
        NSLog(@"already has from view");
    }
    
    if (toView.superview == container) {
        NSLog(@"already has to view");
    }
    
    if (_present) {
        toViewStartFrame.origin.x = containerFrame.size.width;
        toViewStartFrame.origin.y = 0;
        toViewStartFrame.size = containerFrame.size;
        toView.frame = toViewStartFrame;
        
        [container addSubview:toView];
        
        fromViewFinalFrame.origin.x = -containerFrame.size.width/3;
        fromViewFinalFrame.origin.y = 0;
        fromViewFinalFrame.size = containerFrame.size;
    } else {
        toViewStartFrame.origin.x = -containerFrame.size.width/3;
        toViewStartFrame.origin.y = 0;
        toViewStartFrame.size = containerFrame.size;
        toView.frame = toViewStartFrame;
        
        fromViewFinalFrame.origin.x = containerFrame.size.width;
        fromViewFinalFrame.origin.y = 0;
        
        [container addSubview:toView];
        [container bringSubviewToFront:fromView];
    }

    NSTimeInterval t = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:t animations:^{
        fromView.frame = fromViewFinalFrame;
        toView.frame = toViewFinalFrame;
    } completion:^(BOOL finished) {
        BOOL success = ![transitionContext transitionWasCancelled];
        if ((self.present && !success) || (!self.present && success)) {
            [toView removeFromSuperview];
        }
        [transitionContext completeTransition:success];
        
        [tagFromLabel removeFromSuperview];
        [tagToLabel removeFromSuperview];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

@end



@interface TransitionPresentedFakePushPopVC : UIViewController <UIViewControllerTransitioningDelegate>
@end


@implementation TransitionPresentedFakePushPopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transitioningDelegate = self;
    self.view.backgroundColor = [UIColor blueColor];
    
    UIButton *btnDismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    [btnDismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDismiss addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btnDismiss.titleLabel.font = [UIFont systemFontOfSize:17];
    btnDismiss.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:btnDismiss];
    [btnDismiss.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btnDismiss.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)dismissButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    FakePresentAnimator *a = [FakePresentAnimator new];
    a.present = YES;
    return a;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    FakePresentAnimator *a = [FakePresentAnimator new];
    a.present = NO;
    return a;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

@end





@interface TransitionFakePushPopViewController ()

@end

@implementation TransitionFakePushPopViewController

- (void)initView {
    [self showRightBarButtonItemWithName:@"Present a (Push&Pop) VC"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    TransitionPresentedFakePushPopVC *vc = [[TransitionPresentedFakePushPopVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
