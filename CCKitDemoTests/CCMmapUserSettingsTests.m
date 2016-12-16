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

@interface CCMmapUserSettingsTests : XCTestCase {
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

@implementation CCMmapUserSettingsTests

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
    
    BOOL y = [[CCMmapUserSettings sharedUserSettings] synchronize];
    NSLog(@"synchronize result:%@", @(y));
}

- (void)testSaveUserSettings {
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    [[CCMmapUserSettings sharedUserSettings] setObject:number forKey:kNumber];
    [[CCMmapUserSettings sharedUserSettings] setObject:string forKey:kString];
    [[CCMmapUserSettings sharedUserSettings] setObject:data forKey:kData];
    [[CCMmapUserSettings sharedUserSettings] setObject:date forKey:kDate];
    [[CCMmapUserSettings sharedUserSettings] setInteger:integerValue forKey:kInteger];
    [[CCMmapUserSettings sharedUserSettings] setBool:boolValue forKey:kBool];
    [[CCMmapUserSettings sharedUserSettings] setObject:array forKey:kArray];
    [[CCMmapUserSettings sharedUserSettings] setObject:dict forKey:kDictionary];
}

- (void)testLoadUserSettings {
    [[CCMmapUserSettings sharedUserSettings] loadUserSettingsWithUserId:userId];
    XCTAssertTrue([number isEqualToNumber:[[CCMmapUserSettings sharedUserSettings] objectForKey:kNumber]]);
    XCTAssertTrue([string isEqualToString:[[CCMmapUserSettings sharedUserSettings] objectForKey:kString]]);
    XCTAssertTrue([data isEqualToData:[[CCMmapUserSettings sharedUserSettings] objectForKey:kData]]);
    XCTAssertTrue([date isEqualToDate:[[CCMmapUserSettings sharedUserSettings] objectForKey:kDate]]);
    XCTAssertEqual(integerValue, [[CCMmapUserSettings sharedUserSettings] integerForKey:kInteger]);
    XCTAssertEqual(boolValue, [[CCMmapUserSettings sharedUserSettings] boolForKey:kBool]);
    XCTAssertTrue([array isEqualToArray:[[CCMmapUserSettings sharedUserSettings] arrayForKey:kArray]]);
    XCTAssertTrue([dict isEqualToDictionary:[[CCMmapUserSettings sharedUserSettings] dictionaryForKey:kDictionary]]);
}

@end
