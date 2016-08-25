//
//  InteractiveNavigationDelegate.h
//  demo
//
//  Created by KudoCC on 16/8/2.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InteractiveNavigationDelegate : NSObject <UINavigationControllerDelegate>

@property (nonatomic, weak, readonly) UINavigationController *navigationController;

- (instancetype)initWithNavigationController:(UINavigationController *)nav;

@end
