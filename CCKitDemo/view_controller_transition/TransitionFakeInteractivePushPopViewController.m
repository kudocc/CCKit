//
//  TransitionFakeInteractivePushPopViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2018/2/22.
//  Copyright © 2018年 KudoCC. All rights reserved.
//

#import "TransitionFakeInteractivePushPopViewController.h"
#import "TransitionFakePushPopViewController.h"

@interface InteractiveFakePresentAnimator : UIPercentDrivenInteractiveTransition <UIViewControllerInteractiveTransitioning>
@end

@implementation InteractiveFakePresentAnimator

@end



@interface TransitionPresentedInteractiveFakePushPopVC : UIViewController <UIViewControllerTransitioningDelegate> {
    InteractiveFakePresentAnimator *_animator;
}
@end


@implementation TransitionPresentedInteractiveFakePushPopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.transitioningDelegate = self;
    self.view.backgroundColor = [UIColor blueColor];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGR:)];
    [self.view addGestureRecognizer:pan];
}

- (void)panGR:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        InteractiveFakePresentAnimator *animator = [self animator];
        CGPoint p = [pan translationInView:self.view];
        CGFloat f = MIN(p.x, self.view.width);
        f  = f / self.view.width;
        [animator updateInteractiveTransition:f];
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        InteractiveFakePresentAnimator *animator = [self animator];
        CGPoint p = [pan translationInView:self.view];
        CGFloat f = MIN(p.x, self.view.width);
        if (f > 0.1 && [pan locationInView:self.view.window].x > self.view.bounds.size.width/2) {
            [animator finishInteractiveTransition];
        } else {
            [animator cancelInteractiveTransition];
        }
    }
}

- (InteractiveFakePresentAnimator *)animator {
    if (!_animator) {
        _animator = [InteractiveFakePresentAnimator new];
    }
    return _animator;
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

//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
//    return nil;
//}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return [self animator];
}

@end


@interface TransitionFakeInteractivePushPopViewController ()

@end

@implementation TransitionFakeInteractivePushPopViewController

- (void)initView {
    [self showRightBarButtonItemWithName:@"Present a (Push&Pop) VC"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    TransitionPresentedInteractiveFakePushPopVC *vc = [[TransitionPresentedInteractiveFakePushPopVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
