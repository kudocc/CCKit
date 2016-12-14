//
//  PerformanceStoreViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PerformanceStoreViewController.h"
#import <FMDatabaseQueue.h>
#import <FMDB.h>
#import "CCUserSettings.h"

@interface PerformanceStoreViewController ()

@end

@implementation PerformanceStoreViewController

- (void)initView {
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"key"];
        NSDate *begin = [NSDate date];
        for (NSInteger i = 0; i < 1000; ++i) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"key"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSDate *end = [NSDate date];
        NSLog(@"not modified synchronize seconds:%f", [end timeIntervalSinceDate:begin]);
    }
    
    
    {
        NSDate *begin = [NSDate date];
        for (NSInteger i = 0; i < 1000; ++i) {
            [[NSUserDefaults standardUserDefaults] setBool:(i%2==1) forKey:@"key"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSDate *end = [NSDate date];
        NSLog(@"modified synchronize seconds:%f", [end timeIntervalSinceDate:begin]);
    }
    
    {
        [[CCUserSettings sharedUserSettings] loadUserSettingsWithUserId:@"999"];
        NSDate *begin = [NSDate date];
        for (NSInteger i = 0; i < 1000; ++i) {
            [[CCUserSettings sharedUserSettings] synchronize];
        }
        NSDate *end = [NSDate date];
        NSLog(@"CCUserSettings not modified synchronize seconds:%f", [end timeIntervalSinceDate:begin]);
    }
    
    {
        [[CCUserSettings sharedUserSettings] loadUserSettingsWithUserId:@"1000"];
        NSDate *begin = [NSDate date];
        for (NSInteger i = 0; i < 1000; ++i) {
            [[CCUserSettings sharedUserSettings] setBool:(i%2==1) forKey:@"_boolKey"];
            [[CCUserSettings sharedUserSettings] synchronize];
        }
        NSDate *end = [NSDate date];
        NSLog(@"CCUserSettings modified synchronize seconds:%f", [end timeIntervalSinceDate:begin]);
    }
    
    
    {
        // fmdb
        
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [array firstObject];
        path = [path stringByAppendingPathComponent:@"testdb.db"];
        FMDatabaseQueue *dbTest = [[FMDatabaseQueue alloc] initWithPath:path];
        static NSString *const CREATE_TABLE_SQL =
        @"CREATE TABLE IF NOT EXISTS %@ ( \
        id TEXT NOT NULL, \
        json TEXT NOT NULL, \
        createdTime TEXT NOT NULL, \
        PRIMARY KEY(id)) \
        ";
        NSString *sql = [NSString stringWithFormat:CREATE_TABLE_SQL, @"user_table"];
        __block BOOL result;
        [dbTest inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql];
        }];
        if (!result) {
            NSLog(@"ERROR, failed to create table: %@", @"user_table");
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *begin = [NSDate date];
            // insert 100 records 1.35s = 1 record 0.0135s(13.5ms)
            for (NSInteger i = 0; i < 100; ++i) {
                NSString *key = [NSString stringWithFormat:@"%ld", (long)i];
                NSString *string = @"{\"id\":10,\"name\":\"yuanrui\",\"age\":27}, 2016-12-09 06:56:12 +0000";
                NSDate *current = [NSDate date];
                [dbTest inDatabase:^(FMDatabase *db) {
                    [db executeUpdate:@"replace into user_table (id, json, createdTime) values (?, ?, ?)", key, string, current];
                }];
            }
            NSDate *end = [NSDate date];
            NSLog(@"sqlite insert seconds:%f with 100 inserts", [end timeIntervalSinceDate:begin]);
            
            begin = [NSDate date];
            __block NSString *json = nil;
            __block NSDate *createdTime = nil;
            [dbTest inDatabase:^(FMDatabase *db) {
                FMResultSet *rs = [db executeQuery:@"select * from user_table where id = ?", @"10"];
                if (rs.next) {
                    json = [rs stringForColumn:@"json"];
                    createdTime = [rs dateForColumn:@"createdTime"];
                }
                [rs close];
            }];
            end = [NSDate date];
            NSLog(@"%@, %@", json, createdTime);
            NSLog(@"sqlite query seconds:%f", [end timeIntervalSinceDate:begin]);
        });
    }

    // why `[[NSUserDefaults standardUserDefaults] synchronize]` runs so fast!!!!
    {
        // NSUserDefaults
        // 0.096837s    100 times
        // 0.123160s    1000 times
        // 7.789006s    10000 times
        NSDate *begin = [NSDate date];
        for (NSInteger i = 0; i < 1000; ++i) {
            NSString *key = [NSString stringWithFormat:@"%ld", (long)i];
            NSString *string = @"{\"id\":10,\"name\":\"yuanrui\",\"age\":27}, 2016-12-09 06:56:12 +0000";
            [[NSUserDefaults standardUserDefaults] setValue:string forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSDate *end = [NSDate date];
        NSLog(@"NSUserDefaults insert seconds:%f", [end timeIntervalSinceDate:begin]);
    }

    {
        // plist
        // 0.028028s on my iPhone6
        NSDate *begin = [NSDate date];
        NSArray *arrayData = @[@"abc", @"bcd", @"ddd"];
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [array firstObject];
        path = [path stringByAppendingPathComponent:@"test.plist"];
        [arrayData writeToFile:path atomically:YES];
        NSDate *end = [NSDate date];
        NSLog(@"plist insert seconds:%f", [end timeIntervalSinceDate:begin]);
    }
}

@end
