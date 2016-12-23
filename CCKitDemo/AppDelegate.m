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
#import "VideoTableViewController.h"
#import "WebViewController.h"
#import "NetworkViewController.h"
#import "OtherViewController.h"
#import "PerformanceViewController.h"
#import "PersistenceViewController.h"
#import "AudioFileManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    HomeTableViewController *vc = [[HomeTableViewController alloc] init];
    
    vc.arrayTitle = @[@"Core Text",
                      @"Animation",
                      @"Custom Transition",
                      @"Audio",
                      @"Video",
                      @"AutoLayout",
                      @"Quartz 2D",
                      @"Image I/O",
                      @"Core Image",
                      @"Network - Dependency HTTP Task",
                      @"Model",
                      @"Persistence",
                      @"Performance",
                      @"URLSession",
                      @"WebView & WebCache",
                      @"Other"];
    
    vc.arrayClass = @[[CoreTextViewController class],
                      [AnimationViewController class],
                      [VCTransitionViewController class],
                      [AudioViewController class],
                      [VideoTableViewController class],
                      [AutoLayoutViewController class],
                      [Quartz2DViewController class],
                      [ImageIOViewController class],
                      [CoreImageViewController class],
                      [NetworkViewController class],
                      [ModelViewController class],
                      [PersistenceViewController class],
                      [PerformanceViewController class],
                      [UrlSessionViewController class],
                      [WebViewController class],
                      [OtherViewController class]];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [AudioFileManager createAudioDirectory];
    [AudioFileManager createVideoDirectory];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            NSLog(@"AFNetworkReachabilityStatusUnknown");
        } else if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"AFNetworkReachabilityStatusNotReachable");
        } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN");
        } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
        } else {
            NSLog(@"what the fuck????");
        }
        
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
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
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
