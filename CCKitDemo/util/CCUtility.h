//
//  CCUtility.h
//  CCKitDemo
//
//  Created by rui yuan on 2019/9/5.
//  Copyright © 2019 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCUtility : NSObject

+ (NSTimeInterval)calculateTime:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
