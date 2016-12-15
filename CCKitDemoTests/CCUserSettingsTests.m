//
//  CCUserSettingsTests.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/14.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCUserSettings.h"

static NSString *const kNumber = @"number";
static NSString *const kString = @"string";
static NSString *const kData = @"data";
static NSString *const kDate = @"date";
static NSString *const kInteger = @"integer";
static NSString *const kBool = @"bool";
static NSString *const kArray = @"array";
static NSString *const kDictionary = @"dictionary";

@interface CCUserSettingsTests : XCTestCase {
    NSString *userId;
    NSNumber *number;
    NSString *string;
    NSData *data;
    NSDate *date;
    NSInteger integerValue;
    BOOL boolValue;
    NSArray *array;
    NSDictionary *dict;
}

@end

@implementation CCUserSettingsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    userId = @"1024";
    number = @1024;
    string = @"This is a test string";
    data = [string dataUsingEncoding:NSUTF8StringEncoding];
    date = [NSDate dateWithTimeIntervalSince1970:1024];
    integerValue = 10000000;
    boolValue = NO;
    array = @[@1, @2, @3, @4];
    dict = @{@"key1":@"abc", @"key2":@"bcd", @"key3":@1024};
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    BOOL y = [[CCUserSettings sharedUserSettings] synchronize];
    NSLog(@"synchronize result:%@", @(y));
}

- (void)testSaveUserSettings {
    [[CCUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    [[CCUserSettings sharedUserSettings] setObject:number forKey:kNumber];
    [[CCUserSettings sharedUserSettings] setObject:string forKey:kString];
    [[CCUserSettings sharedUserSettings] setObject:data forKey:kData];
    [[CCUserSettings sharedUserSettings] setObject:date forKey:kDate];
    [[CCUserSettings sharedUserSettings] setInteger:integerValue forKey:kInteger];
    [[CCUserSettings sharedUserSettings] setBool:boolValue forKey:kBool];
    [[CCUserSettings sharedUserSettings] setObject:array forKey:kArray];
    [[CCUserSettings sharedUserSettings] setObject:dict forKey:kDictionary];
}

- (void)testLoadUserSettings {
    [[CCUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    XCTAssertTrue([number isEqualToNumber:[[CCUserSettings sharedUserSettings] objectForKey:kNumber]]);
    XCTAssertTrue([string isEqualToString:[[CCUserSettings sharedUserSettings] objectForKey:kString]]);
    XCTAssertTrue([data isEqualToData:[[CCUserSettings sharedUserSettings] objectForKey:kData]]);
    XCTAssertTrue([date isEqualToDate:[[CCUserSettings sharedUserSettings] objectForKey:kDate]]);
    XCTAssertEqual(integerValue, [[CCUserSettings sharedUserSettings] integerForKey:kInteger]);
    XCTAssertEqual(boolValue, [[CCUserSettings sharedUserSettings] boolForKey:kBool]);
    XCTAssertTrue([array isEqualToArray:[[CCUserSettings sharedUserSettings] arrayForKey:kArray]]);
    XCTAssertTrue([dict isEqualToDictionary:[[CCUserSettings sharedUserSettings] dictionaryForKey:kDictionary]]);
}

@end
