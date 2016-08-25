//
//  ImageTransitionViewController.m
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageTransitionViewController.h"
#import "ImagePickerViewController.h"

@interface ImageTransitionViewController () <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning> {
    UIImageView *_imageView;
}

@end

@implementation ImageTransitionViewController

- (void)initView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0, 200.0)];
    [self.view addSubview:_imageView];
    _imageView.center = self.view.center;
    _imageView.userInteractionEnabled = YES;
    _imageView.image = [UIImage imageNamed:@"conan2"];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGR:)];
    [_imageView addGestureRecognizer:tapGR];
}

- (void)tapGR:(id)gr {
    self.navigationController.delegate = self;
    
    ImagePickerViewController *vc = [[ImagePickerViewController alloc] init];
    vc.image = _imageView.image;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        return self;
    }
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ImagePickerViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    [container addSubview:toVC.view];
    toVC.view.alpha = 0.0;
    CGRect frameImage = toVC.imageFrame;
    
    CGRect frameOri = _imageView.frame;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        _imageView.frame = frameImage;
        toVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        _imageView.frame = frameOri;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
