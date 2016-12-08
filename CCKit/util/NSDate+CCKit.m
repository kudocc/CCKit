//
//  NSDate+CCKit.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "NSDate+CCKit.h"

@implementation NSDate (CCKit)

- (NSString *)cc_stringWithFormatterString:(NSString *)formatterString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:self];
}

@end
