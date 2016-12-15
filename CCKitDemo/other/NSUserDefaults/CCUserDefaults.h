//
//  CCUserDefaults.h
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCUserDefaults : NSObject

+ (instancetype)sharedUserDefaults;

- (void)loadUserSettingsWithUserId:(NSString *)userId;

- (nullable id)objectForKey:(NSString *)key;
- (BOOL)setObject:(nullable id)value forKey:(NSString *)key;
/// -removeObjectForKey: is equivalent to -[... setObject:nil forKey:key]
- (BOOL)removeObjectForKey:(NSString *)key;

- (nullable NSString *)stringForKey:(NSString *)key;
- (nullable NSNumber *)numberForKey:(NSString *)key;
- (nullable NSData *)dataForKey:(NSString *)key;
- (nullable NSDate *)dateForKey:(NSString *)key;
- (nullable NSArray *)arrayForKey:(NSString *)key;
- (nullable NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)key;

- (NSInteger)integerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

- (BOOL)setInteger:(NSInteger)value forKey:(NSString *)key;
- (BOOL)setFloat:(float)value forKey:(NSString *)key;
- (BOOL)setDouble:(double)value forKey:(NSString *)key;
- (BOOL)setBool:(BOOL)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
