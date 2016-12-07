//
//  CCRemoteNotificationManager.h
//  dodopay
//
//  Created by KudoCC on 2016/12/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCRemoteNotificationManager : NSObject

+ (instancetype)sharedManager;

- (void)requestAuthorization;
- (void)requestUserNotificationSettings;

- (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

@end
