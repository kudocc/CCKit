//
//  Student.m
//  CCKitDemo
//
//  Created by KudoCC on 16/10/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "Student.h"

@implementation Student

+ (NSDictionary<NSString *, NSString *> *)propertyNameToJsonKeyMap {
    return @{@"grade":@"g"};
}
- (void)modelFinishConstructFromJSONObject:(NSDictionary *)jsonObject {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
- (void)JSONObjectFinishConstructFromModel:(NSMutableDictionary *)jsonObject {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    return [self ccmodel_isEqual:object];
}

- (NSUInteger)hash {
    return [self ccmodel_hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [self ccmodel_copyWithZone:zone];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self ccmodel_encodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self ccmodel_initWithCoder:coder];
}

@end
