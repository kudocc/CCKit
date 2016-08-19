//
//  NSString+CCKit.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSString+CCKit.h"

@implementation NSString (FilePath)

+ (NSString *)cc_documentPath {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [array firstObject];
}

@end


@implementation NSString (CCKit)

- (unichar)cc_lastCharacter {
    if (self.length > 0) {
        return [self characterAtIndex:self.length-1];
    } else {
        return 0;
    }
}

- (NSString *)cc_stringByTrimLastTrivalZero {
    NSRange range = [self rangeOfString:@"."];
    if (range.location == NSNotFound) {
        return [self copy];
    } else {
        // We find '.'
        NSRange rangeTrim = NSMakeRange(NSNotFound, 0);
        for (NSInteger i = [self length]-1; i > range.location; --i) {
            if ([self characterAtIndex:i] == '0') {
                rangeTrim.location = i;
                ++rangeTrim.length;
            } else {
                break;
            }
        }
        if (rangeTrim.location != NSNotFound) {
            NSRange subRange = NSMakeRange(0, [self length] - rangeTrim.length);
            NSString *subStr = [self substringWithRange:subRange];
            if ([subStr cc_lastCharacter] == '.') {
                subStr = [subStr substringToIndex:subRange.length-1];
            }
            return subStr;
        } else {
            return [self copy];
        }
    }
}

- (BOOL)cc_isValidEmail {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (NSString *)cc_stringByRemovingCharactersInCharacterSet:(NSCharacterSet *)characterSet {
    NSArray *array = [self componentsSeparatedByCharactersInSet:characterSet];
    return [array componentsJoinedByString:@""];
}

- (void)cc_runUntilNoneSpaceFromLocation:(NSInteger)location noneSpaceLocation:(NSInteger *)noneSpaceLocation reachEnd:(BOOL *)end {
    [self cc_runUntilCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:@" "] invertedSet]
                  fromLocation:location
                 reachLocation:noneSpaceLocation
                      reachEnd:end];
}

- (void)cc_runUntilCharacterSet:(NSCharacterSet *)characterSet fromLocation:(NSInteger)location reachLocation:(NSInteger *)reachLocation reachEnd:(BOOL *)end {
    while (location < [self length]) {
        unichar c = [self characterAtIndex:location];
        if ([characterSet characterIsMember:c]) {
            if (reachLocation) *reachLocation = location;
            if (end) *end = NO;
            return;
        }
        ++location;
    }
    if (reachLocation) *reachLocation = location;
    if (end) *end = YES;
}

- (NSString *)cc_transformToPinyin {
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [mutableString stringByReplacingOccurrencesOfString:@"'" withString:@""];
}

@end


@implementation NSMutableString (CCKit)

- (void)cc_deleteCharacterInCharacterSet:(NSCharacterSet *)characterSet {
    NSRange range = NSMakeRange(NSNotFound, 0);
    NSInteger i = 0;
    while (i < self.length) {
        for (; i < self.length; ++i) {
            unichar c = [self characterAtIndex:i];
            if ([characterSet characterIsMember:c]) {
                if (range.location == NSNotFound) {
                    range.location = i;
                    range.length = 1;
                } else {
                    ++range.length;
                }
            } else if (range.location != NSNotFound) {
                [self deleteCharactersInRange:range];
                
                // begin next walk from i
                i = range.location;
                
                // reset range
                range.location = NSNotFound;
                range.length = 0;
                
                break;
            }
        }
    }
    if (range.location != NSNotFound) {
        [self deleteCharactersInRange:range];
    }
}

@end