//
//  CCMmapUserSettings.h
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The synchronize in CCUserSettings or NSUserDefaults method writes the plist file back to the disk, it costs notable time, but we must call it in some situations like when app goes into background. Even so we take the risk of losing the settings: we apps may be killed by system because it runs out of memory or accesses a address which it hasn't permission to, at that time the settings we set after the latest synchronize may lose.
 
 If there is a way that we can write the file to the disk when the process exits, we can modify the settings in memory all the time, it's pretty fast. But is there a way to achieve that ?
 
 Well, I find one, it is mmap, mmap maps a file to a region of memory. When this is done, the file can be accessed just like an array in the program. So we can modify the memory as if we write the file. When process exits, the memory will write back to the file.
 
 CCMmapUserSettings passes the unit settings on my iPhone6 (iOS 10.1.1) and iPhone4 (iOS 7.1.2), but I really not sure if it works on all iOS versions because I haven't gotten a official document to make sure the memory used to map the file will be written back to disk immediately when the process exits, if it's not, will it be written to disk before the device shuts down ?
 
 */
@interface CCMmapUserSettings : NSObject

+ (instancetype)sharedUserSettings;

/// default is NO, if YES, it will call `synchronize` automatically every time you modify the settings.
@property (nonatomic) BOOL automaticSynchronize;

- (void)loadUserSettingsWithUserId:(NSString *)userId;

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(nullable id)value forKey:(NSString *)key;
/// -removeObjectForKey: is equivalent to -[... setObject:nil forKey:key]
- (void)removeObjectForKey:(NSString *)key;

/// -stringForKey: is equivalent to -objectForKey:, except that it will convert NSNumber values to their NSString representation. If a non-string non-number value is found, nil will be returned.
- (nullable NSString *)stringForKey:(NSString *)key;

/// -arrayForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray.
- (nullable NSArray *)arrayForKey:(NSString *)key;
/// -dictionaryForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSDictionary.
- (nullable NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)key;
/// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
- (nullable NSData *)dataForKey:(NSString *)key;

/*!
 -integerForKey: is equivalent to -objectForKey:, except that it converts the returned value to an NSInteger. If the value is an NSNumber, the result of -integerValue will be returned. If the value is an NSString, it will be converted to NSInteger if possible. If the value is a boolean, it will be converted to either 1 for YES or 0 for NO. If the value is absent or can't be converted to an integer, 0 will be returned.
 */
- (NSInteger)integerForKey:(NSString *)key;

/// -floatForKey: is similar to -integerForKey:, except that it returns a float, and boolean values will not be converted.
- (float)floatForKey:(NSString *)key;
/// -doubleForKey: is similar to -doubleForKey:, except that it returns a double, and boolean values will not be converted.
- (double)doubleForKey:(NSString *)key;
/*!
 -boolForKey: is equivalent to -objectForKey:, except that it converts the returned value to a BOOL. If the value is an NSNumber, NO will be returned if the value is 0, YES otherwise. If the value is an NSString, values of "YES" or "1" will return YES, and values of "NO", "0", or any other string will return NO. If the value is absent or can't be converted to a BOOL, NO will be returned.
 */
- (BOOL)boolForKey:(NSString *)key;

/*!
 -URLForKey: is equivalent to -objectForKey: except that it converts the returned value to an NSURL. If the value is an NSString path, then it will construct a file URL to that path. If the value is an archived URL from -setURL:forKey: it will be unarchived. If the value is absent or can't be converted to an NSURL, nil will be returned.
 */
//- (nullable NSURL *)URLForKey:(NSString *)key;

/// -setInteger:forKey: is equivalent to -setObject:forKey: except that the value is converted from an NSInteger to an NSNumber.
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
/// -setFloat:forKey: is equivalent to -setObject:forKey: except that the value is converted from a float to an NSNumber.
- (void)setFloat:(float)value forKey:(NSString *)key;
/// -setDouble:forKey: is equivalent to -setObject:forKey: except that the value is converted from a double to an NSNumber.
- (void)setDouble:(double)value forKey:(NSString *)key;
/// -setBool:forKey: is equivalent to -setObject:forKey: except that the value is converted from a BOOL to an NSNumber.
- (void)setBool:(BOOL)value forKey:(NSString *)key;
/// -setURL:forKey is equivalent to -setObject:forKey: except that the value is archived to an NSData. Use -URLForKey: to retrieve values set this way.
//- (void)setURL:(nullable NSURL *)url forKey:(NSString *)key;

- (BOOL)synchronize;

@end

NS_ASSUME_NONNULL_END
