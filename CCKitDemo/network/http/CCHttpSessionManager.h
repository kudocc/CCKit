//
//  CCHttpSessionManager.h
//  demo
//
//  Created by KudoCC on 16/5/23.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface CCHttpSessionManager : NSObject

+ (instancetype)sharedManager;

- (AFHTTPSessionManager *)sessionManagerForBaseURL:(NSURL *)baseURL;

@end
