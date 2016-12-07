//
//  CCRemoteNotificationManager.m
//  dodopay
//
//  Created by KudoCC on 2016/12/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCRemoteNotificationManager.h"
#import <UserNotifications/UserNotifications.h>

@interface CCRemoteNotificationManager () <UNUserNotificationCenterDelegate>

@end

@implementation CCRemoteNotificationManager

+ (instancetype)sharedManager {
    static CCRemoteNotificationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCRemoteNotificationManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    return self;
}

- (void)requestAuthorization {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // Enable or disable features based on authorization.
                              NSLog(@"granted:%@, error:%@", @(granted), error.localizedDescription);
                          }];
}

- (void)requestUserNotificationSettings {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge+UIUserNotificationTypeSound+UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark -

- (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    NSString *deviceToken = [[[[token description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@, devToken=%@", NSStringFromSelector(_cmd), deviceToken);
    // Forward the token to your server.
    //[self enableRemoteNotificationFeatures];
    //[self forwardTokenToServer:devTokenBytes];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@, error:%@", NSStringFromSelector(_cmd), [error localizedDescription]);
    //NSLog(@"Remote notification support is unavailable due to error: %@", err);
    //[self disableRemoteNotificationFeatures];
}

#pragma mark -

/*
 If your app is in the foreground when a notification arrives, the notification center calls this method to deliver the notification directly to your app. If you implement this method, you can take whatever actions are necessary to process the notification and update your app. When you finish, execute the completionHandler block and specify how you want the system to alert the user, if at all.
 If your delegate does not implement this method, the system silences alerts as if you had passed the UNNotificationPresentationOptionNone option to the completionHandler block. If you do not provide a delegate at all for the UNUserNotificationCenter object, the system uses the notification’s original options to alert the user.
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    completionHandler(UNNotificationPresentationOptionAlert);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    NSLog(@"notification info [%@], app state:%ld", response.notification.request.content.userInfo, (long)[UIApplication sharedApplication].applicationState);
    
    completionHandler();
}

@end
