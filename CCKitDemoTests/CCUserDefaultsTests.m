//
//  CCUserDefaultsTests.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCUserDefaults.h"

static NSString *const kNumber = @"number";
static NSString *const kString = @"string";
static NSString *const kData = @"data";
static NSString *const kDate = @"date";
static NSString *const kInteger = @"integer";
static NSString *const kBool = @"bool";
static NSString *const kArray = @"array";
static NSString *const kDictionary = @"dictionary";

@interface CCUserDefaultsTests : XCTestCase {
    NSString *userId;
    NSString *anotherUserId;
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

@implementation CCUserDefaultsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    userId = @"1024";
    anotherUserId = @"1025";
    number = @1024;
    string = @"This is a test string";
    data = [string dataUsingEncoding:NSUTF8StringEncoding];
    date = [NSDate dateWithTimeIntervalSince1970:3600*24];
    integerValue = 10000000;
    boolValue = NO;
    array = @[@1, @2, @3, @4];
    dict = @{@"key1":@"abc", @"key2":@"bcd", @"key3":@1024};
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveUserSettings {
    [[CCUserDefaults sharedUserDefaults] loadUserSettingsWithUserId:userId];
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:number forKey:kNumber]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:string forKey:kString]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:data forKey:kData]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:date forKey:kDate]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setInteger:integerValue forKey:kInteger]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setBool:boolValue forKey:kBool]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:array forKey:kArray]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:dict forKey:kDictionary]);
    
    // load another user
    [[CCUserDefaults sharedUserDefaults] loadUserSettingsWithUserId:anotherUserId];
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:number forKey:kNumber]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:string forKey:kString]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:data forKey:kData]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:date forKey:kDate]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setInteger:integerValue forKey:kInteger]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setBool:boolValue forKey:kBool]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:array forKey:kArray]);
    XCTAssertTrue([[CCUserDefaults sharedUserDefaults] setObject:dict forKey:kDictionary]);
}

- (void)testLoadUserSettings {
    [[CCUserDefaults sharedUserDefaults] loadUserSettingsWithUserId:userId];
    XCTAssertTrue([number isEqualToNumber:[[CCUserDefaults sharedUserDefaults] numberForKey:kNumber]]);
    XCTAssertTrue([string isEqualToString:[[CCUserDefaults sharedUserDefaults] stringForKey:kString]]);
    XCTAssertTrue([data isEqualToData:[[CCUserDefaults sharedUserDefaults] dataForKey:kData]]);
    XCTAssertTrue([date isEqualToDate:[[CCUserDefaults sharedUserDefaults] dateForKey:kDate]]);
    XCTAssertEqual(integerValue, [[CCUserDefaults sharedUserDefaults] integerForKey:kInteger]);
    XCTAssertEqual(boolValue, [[CCUserDefaults sharedUserDefaults] boolForKey:kBool]);
    XCTAssertTrue([array isEqualToArray:[[CCUserDefaults sharedUserDefaults] arrayForKey:kArray]]);
    XCTAssertTrue([dict isEqualToDictionary:[[CCUserDefaults sharedUserDefaults] dictionaryForKey:kDictionary]]);
    
    // load another user
    [[CCUserDefaults sharedUserDefaults] loadUserSettingsWithUserId:anotherUserId];
    XCTAssertTrue([number isEqualToNumber:[[CCUserDefaults sharedUserDefaults] numberForKey:kNumber]]);
    XCTAssertTrue([string isEqualToString:[[CCUserDefaults sharedUserDefaults] stringForKey:kString]]);
    XCTAssertTrue([data isEqualToData:[[CCUserDefaults sharedUserDefaults] dataForKey:kData]]);
    XCTAssertTrue([date isEqualToDate:[[CCUserDefaults sharedUserDefaults] dateForKey:kDate]]);
    XCTAssertEqual(integerValue, [[CCUserDefaults sharedUserDefaults] integerForKey:kInteger]);
    XCTAssertEqual(boolValue, [[CCUserDefaults sharedUserDefaults] boolForKey:kBool]);
    XCTAssertTrue([array isEqualToArray:[[CCUserDefaults sharedUserDefaults] arrayForKey:kArray]]);
    XCTAssertTrue([dict isEqualToDictionary:[[CCUserDefaults sharedUserDefaults] dictionaryForKey:kDictionary]]);
}

@end
