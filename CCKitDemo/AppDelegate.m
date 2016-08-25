//
//  AppDelegate.m
//  CCKitDemo
//
//  Created by KudoCC on 16/8/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeTableViewController.h"
#import "CoreTextViewController.h"
#import "AnimationViewController.h"
#import "VCTransitionViewController.h"
#import "AutoLayoutViewController.h"
#import "Quartz2DViewController.h"
#import "ImageIOViewController.h"
#import "CoreImageViewController.h"
#import "ModelViewController.h"
#import "UrlSessionViewController.h"
#import "AudioViewController.h"
#import "WebViewController.h"
#import "NetworkViewController.h"
#import "OtherViewController.h"
#import "PerformanceViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    HomeTableViewController *vc = [[HomeTableViewController alloc] init];
    vc.arrayTitle = @[@"Core Text",
                      @"Animation",
                      @"Custom Transition",
                      @"Audio",
                      @"AutoLayout",
                      @"Quartz 2D",
                      @"Image I/O",
                      @"Core Image",
                      @"Network - Dependency HTTP Task",
                      @"Model",
                      @"Performance",
                      @"URLSession",
                      @"WebView & WebCache",
                      @"Other"];
    vc.arrayClass = @[[CoreTextViewController class],
                      [AnimationViewController class],
                      [VCTransitionViewController class],
                      [AudioViewController class],
                      [AutoLayoutViewController class],
                      [Quartz2DViewController class],
                      [ImageIOViewController class],
                      [CoreImageViewController class],
                      [NetworkViewController class],
                      [ModelViewController class],
                      [PerformanceViewController class],
                      [UrlSessionViewController class],
                      [WebViewController class],
                      [OtherViewController class]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    
    // 假设整个区域的大小是200*200px，scale是2，srcPoint所在位置为(10, 10)point，被转换成Quartz的坐标系的位置应该是(20, 180)px
    // srcPoint位于UIKit的坐标系中，UIKit要使用仿射变换使其变成Quartz的坐标系，我们模拟了这个过程
    // 在看代码之前，我们要考虑Quartz的坐标系是什么样的，我觉得Quartz应该跟`CGBitmapContextCreate`创建的context中使用的坐标系是一样的
    // 而这个context，我用`CGContextGetCTM(context)`拿到的坐标系仿射变换的值为[1, 0, 0, 1, 0, 0]
    // 因为UIKit中使用的是point，并且是以左上角为原点，所以UIKit要应用仿射变换将scrPoint的点变成同样位置的Quartz的点
    // Height为区域的大小，单位是point
    // 如果scale为1，将srcPoint转换成Quartz的位置应该是 (srcPoint.x, Height - srcPoint.y)
    // 如果scale大于1，那么应该是(srcPoint.x * scale, (Height - srcPoint.y) * scale)
    // 所以可以做如下仿射变换，这应该就是UIKit创建CGContext时对CGContext做的仿射变换
    // 这里要注意的是这个函数以及相关的对transform做变换的函数，以CGAffineTransformTranslate(transform, x, y)为例
    // 他是将CGAffineTransformMakeTranslation(x, y)的结果与transform做矩阵相乘
    // 而不是transform与CGAffineTransformMakeTranslation(x, y)的结果相乘，矩阵相乘交换律不成立，所以千万小心
    /*
     CGPoint srcPoint = CGPointMake(10, 10);
     
     CGFloat scale = [UIScreen mainScreen].scale;
     
     CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
     NSLog(@"%@", NSStringFromCGAffineTransform(transform));
     
     transform = CGAffineTransformTranslate(transform, 0, 100);
     NSLog(@"%@", NSStringFromCGAffineTransform(transform));
     
     transform = CGAffineTransformScale(transform, 1, -1);
     NSLog(@"%@", NSStringFromCGAffineTransform(transform));
     
     CGPoint dstPoint = CGPointApplyAffineTransform(srcPoint, transform);
     NSLog(@"src point:%@", NSStringFromCGPoint(srcPoint));
     NSLog(@"det point:%@", NSStringFromCGPoint(dstPoint));
     */
    /*
     CGAffineTransform transform = CGAffineTransformMakeScale(1/scale, 1/scale);
     NSLog(@"%@", NSStringFromCGAffineTransform(transform));
     transform = CGAffineTransformScale(transform, 1, -1);
     NSLog(@"%@", NSStringFromCGAffineTransform(transform));
     transform = CGAffineTransformTranslate(transform, 0, -200);
     NSLog(@"%@", NSStringFromCGAffineTransform(transform));
     */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end