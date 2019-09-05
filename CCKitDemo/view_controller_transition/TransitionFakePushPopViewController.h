//
//  TransitionFakePushPopViewController.h
//  CCKitDemo
//
//  Created by kudocc on 2018/2/11.
//  Copyright © 2018年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

@interface FakePresentAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL present;

@end

@interface TransitionFakePushPopViewController : BaseViewController

@end
