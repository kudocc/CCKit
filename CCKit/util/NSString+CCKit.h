//
//  NSString+CCKit.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FilePath)

+ (NSString *)cc_documentPath;

@end

@interface NSString (CCKit)

/**
 if string length is zero, return 0.
 */
- (unichar)cc_lastCharacter;

/**
 remove the trival zeroes at the end of string
 for example: 1000->1000, 0.100->0.1, 1.00->1
 */
- (NSString *)cc_stringByTrimLastTrivalZero;

/**
 return YES if receiver is a valid email
 */
- (BOOL)cc_isValidEmail;

/**
 remove all charaters contain in characterSet.
 */
- (NSString *)cc_stringByRemovingCharactersInCharacterSet:(NSCharacterSet *)characterSet;

/**
 Call `cc_runUntilCharacterSet` with [[NSCharacterSet characterSetWithCharactersInString:@" "] invertedSet] as characterSet parameter
 */
- (void)cc_runUntilNoneSpaceFromLocation:(NSInteger)location noneSpaceLocation:(NSInteger *)noneSpaceLocation reachEnd:(BOOL *)end;
/**
 @param walk the string until we meet a character in characterSet
 @param location walk from the location
 @param reachLocation if we find a character in characterSet, the location points to that character, else the location points to the last character + 1
 */
- (void)cc_runUntilCharacterSet:(NSCharacterSet *)characterSet fromLocation:(NSInteger)location reachLocation:(NSInteger *)reachLocation reachEnd:(BOOL *)end;

/**
 @"北京"->@"bei jing"
 */
- (NSString *)cc_transformToPinyin;

@end


@interface NSMutableString (CCKit)

- (void)cc_deleteCharacterInCharacterSet:(NSCharacterSet *)characterSet;

@end