//
//  CCMmapUserSettingsTests.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCMmapUserSettings.h"

static NSString *const kNumber = @"number";
static NSString *const kString = @"string";
static NSString *const kData = @"data";
static NSString *const kDate = @"date";
static NSString *const kInteger = @"integer";
static NSString *const kBool = @"bool";
static NSString *const kArray = @"array";
static NSString *const kDictionary = @"dictionary";
static NSString *const kOnePageData = @"one_page_data";

@interface CCMmapUserSettingsTests : XCTestCase {
    NSString *userId;
    NSString *anotherUserId;
    NSNumber *number;
    NSNumber *anotherNumber;
    NSString *string;
    NSData *data;
    NSDate *date;
    NSInteger integerValue;
    BOOL boolValue;
    NSArray *array;
    NSDictionary *dict;
}

@end

@implementation CCMmapUserSettingsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    userId = @"1024";
    anotherUserId = @"1025";
    number = @1024;
    anotherNumber = @1025;
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
}

// we must test save before test load
// #1
- (void)test1_saveUserSettings {
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    [[CCMmapUserSettings sharedUserSettings] setObject:number forKey:kNumber];
    [[CCMmapUserSettings sharedUserSettings] setObject:string forKey:kString];
    [[CCMmapUserSettings sharedUserSettings] setObject:data forKey:kData];
    [[CCMmapUserSettings sharedUserSettings] setObject:date forKey:kDate];
    [[CCMmapUserSettings sharedUserSettings] setInteger:integerValue forKey:kInteger];
    [[CCMmapUserSettings sharedUserSettings] setBool:boolValue forKey:kBool];
    [[CCMmapUserSettings sharedUserSettings] setObject:array forKey:kArray];
    [[CCMmapUserSettings sharedUserSettings] setObject:dict forKey:kDictionary];
    XCTAssertTrue([[CCMmapUserSettings sharedUserSettings] synchronize]);
    
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:anotherUserId];
    [[CCMmapUserSettings sharedUserSettings] setObject:anotherNumber forKey:kNumber];
    [[CCMmapUserSettings sharedUserSettings] setObject:string forKey:kString];
    [[CCMmapUserSettings sharedUserSettings] setObject:data forKey:kData];
    [[CCMmapUserSettings sharedUserSettings] setObject:date forKey:kDate];
    [[CCMmapUserSettings sharedUserSettings] setInteger:integerValue forKey:kInteger];
    [[CCMmapUserSettings sharedUserSettings] setBool:boolValue forKey:kBool];
    [[CCMmapUserSettings sharedUserSettings] setObject:array forKey:kArray];
    [[CCMmapUserSettings sharedUserSettings] setObject:dict forKey:kDictionary];
    XCTAssertTrue([[CCMmapUserSettings sharedUserSettings] synchronize]);
}

// we must test save before test load
// #2
- (void)test2_loadUserSettings {
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    XCTAssertTrue([number isEqualToNumber:[[CCMmapUserSettings sharedUserSettings] objectForKey:kNumber]]);
    XCTAssertTrue([string isEqualToString:[[CCMmapUserSettings sharedUserSettings] objectForKey:kString]]);
    XCTAssertTrue([data isEqualToData:[[CCMmapUserSettings sharedUserSettings] objectForKey:kData]]);
    XCTAssertTrue([date isEqualToDate:[[CCMmapUserSettings sharedUserSettings] objectForKey:kDate]]);
    XCTAssertEqual(integerValue, [[CCMmapUserSettings sharedUserSettings] integerForKey:kInteger]);
    XCTAssertEqual(boolValue, [[CCMmapUserSettings sharedUserSettings] boolForKey:kBool]);
    XCTAssertTrue([array isEqualToArray:[[CCMmapUserSettings sharedUserSettings] arrayForKey:kArray]]);
    XCTAssertTrue([dict isEqualToDictionary:[[CCMmapUserSettings sharedUserSettings] dictionaryForKey:kDictionary]]);
    
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:anotherUserId];
    XCTAssertTrue([anotherNumber isEqualToNumber:[[CCMmapUserSettings sharedUserSettings] objectForKey:kNumber]]);
    XCTAssertTrue([string isEqualToString:[[CCMmapUserSettings sharedUserSettings] objectForKey:kString]]);
    XCTAssertTrue([data isEqualToData:[[CCMmapUserSettings sharedUserSettings] objectForKey:kData]]);
    XCTAssertTrue([date isEqualToDate:[[CCMmapUserSettings sharedUserSettings] objectForKey:kDate]]);
    XCTAssertEqual(integerValue, [[CCMmapUserSettings sharedUserSettings] integerForKey:kInteger]);
    XCTAssertEqual(boolValue, [[CCMmapUserSettings sharedUserSettings] boolForKey:kBool]);
    XCTAssertTrue([array isEqualToArray:[[CCMmapUserSettings sharedUserSettings] arrayForKey:kArray]]);
    XCTAssertTrue([dict isEqualToDictionary:[[CCMmapUserSettings sharedUserSettings] dictionaryForKey:kDictionary]]);
}

- (void)test3_saveMoreThanOnePageDataAndRestoreToLessOnePageData {
    // write more data, over one memory page
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    char c[4096] = {0};
    NSData *largeData = [NSData dataWithBytes:c length:4096];
    [[CCMmapUserSettings sharedUserSettings] setObject:largeData forKey:kOnePageData];
    XCTAssertTrue([[CCMmapUserSettings sharedUserSettings] synchronize]);
    
    // restore to one page
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    [[CCMmapUserSettings sharedUserSettings] setObject:nil forKey:kOnePageData];
    XCTAssertTrue([[CCMmapUserSettings sharedUserSettings] synchronize]);
}

@end
