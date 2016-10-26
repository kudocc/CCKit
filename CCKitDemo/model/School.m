//
//  School.m
//  CCKitDemo
//
//  Created by KudoCC on 16/10/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "School.h"

@implementation School

#pragma mark - CCModel

+ (NSDictionary<NSString *, NSString *> *)propertyNameToJsonKeyMap {
    return @{@"studentCount":@"people.student.count",
             @"teacherCount":@"people.teacher.count"};
}

+ (NSDictionary<NSString *, ContainerTypeObject *> *)propertyNameToContainerTypeObjectMap {
    ContainerTypeObject *countObj = [[ContainerTypeObject alloc] initWithClass:[NSNumber class]];
    
    ContainerTypeObject *arrayStudent = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[Student class]];
    ContainerTypeObject *arrayTeacher = [ContainerTypeObject arrayContainerTypeObjectWithValueClass:[Teacher class]];
    
    ContainerTypeObject *dictStudent = [ContainerTypeObject dictionaryContainerTypeObjectWithKeyToValueClass:@{@"count":countObj, @"value":arrayStudent}];
    ContainerTypeObject *dictTeacher = [ContainerTypeObject dictionaryContainerTypeObjectWithKeyToValueClass:@{@"count":countObj, @"value":arrayTeacher}];
    
    ContainerTypeObject *dictPeople = [ContainerTypeObject dictionaryContainerTypeObjectWithKeyToValueClass:@{@"student":dictStudent, @"teacher":dictTeacher}];
    
    return @{@"people": dictPeople};
}

+ (NSSet<NSString *> *)propertyNameCalculateHash {
    return [NSSet setWithObjects:@"schoolId", nil];
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
