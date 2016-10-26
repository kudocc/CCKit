//
//  School.h
//  CCKitDemo
//
//  Created by KudoCC on 16/10/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+CCModel.h"
#import "Student.h"
#import "Teacher.h"

@interface School : NSObject <CCModel, NSCoding, NSCopying>

@property NSString *schoolId;

/// the first key @"student", value is a NSDictionary-> {@"count":@1, @"value":@[]} "value" is array of Student
/// the second key @"teacher", value is a NSDictionary-> {@"count":@1, @"value":@[]} the value of the key "value" is array of Teacher
@property NSDictionary *people;

@property NSURL *homePageURL;

@property NSInteger studentCount;
@property NSInteger teacherCount;

@end
