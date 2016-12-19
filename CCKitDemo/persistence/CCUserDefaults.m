//
//  CCUserDefaults.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/15.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCUserDefaults.h"
#import "NSString+CCKit.h"
#import <FMDB.h>
#import <FMDatabaseQueue.h>

static NSString *kUserDefaultsStringType = @"string";
static NSString *kUserDefaultsNumberType = @"number";
static NSString *kUserDefaultsDataType = @"data";
static NSString *kUserDefaultsDateType = @"date";
static NSString *kUserDefaultsArrayType = @"array";
static NSString *kUserDefaultsDictionaryType = @"dictionary";

static NSString *kUserDefaultsDatabaseName = @"user_defaults.data";
static NSString *kUserDefaultsDirectoryName = @"user_defaults";
static NSString *kUserDefaultsTableNamePrefix = @"table";

NSString *UPDATE_PROPERTY_TABLE = @"REPLACE INTO %@(key, type, value) values (?, ?, ?)";
NSString *QUERY_PROPERTY_TABLE = @"SELECT key, type, value FROM %@ where key=?";
NSString *DELETE_PROPERTY_TABLE = @"DELETE FROM %@ where key=?";

@interface DataBaseObject : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *type;
@property (nonatomic) id value;

- (instancetype)initWithResult:(FMResultSet *)result NS_DESIGNATED_INITIALIZER;

@end

@implementation DataBaseObject

- (instancetype)initWithResult:(FMResultSet *)result {
    self = [super init];
    if (self) {
        if (result.next) {
            _key = [result stringForColumn:@"key"];
            _type = [result stringForColumn:@"type"];
            NSString *valueColumnName = @"value";
            if ([_type isEqualToString:kUserDefaultsStringType] ||
                [_type isEqualToString:kUserDefaultsNumberType]) {
                _value = [result stringForColumn:valueColumnName];
            } else if ([_type isEqualToString:kUserDefaultsDataType] ||
                       [_type isEqualToString:kUserDefaultsArrayType] ||
                       [_type isEqualToString:kUserDefaultsDictionaryType]) {
                _value = [result dataForColumn:valueColumnName];
            } else if ([_type isEqualToString:kUserDefaultsDateType]) {
                _value = [result dateForColumn:valueColumnName];
            } else {
                NSLog(@"error type:%@", _type);
            }
            [result close];
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithResult:nil];
}

@end

@interface CCUserDefaults ()

@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *dbPath;
@property (nonatomic) NSString *tableName;
@property (nonatomic) FMDatabaseQueue *dbQueue;

@end

@implementation CCUserDefaults

+ (instancetype)sharedUserDefaults {
    static dispatch_once_t onceToken;
    static CCUserDefaults *userDefaults;
    dispatch_once(&onceToken, ^{
        userDefaults = [[CCUserDefaults alloc] init];
    });
    return userDefaults;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *dirPath = [NSString cc_documentPath];
        dirPath = [dirPath stringByAppendingPathComponent:kUserDefaultsDirectoryName];
        _dbPath = [dirPath stringByAppendingPathComponent:kUserDefaultsDatabaseName];
        BOOL dir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&dir] || !dir) {
            BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
            if (!res) {
                NSLog(@"Create directory:%@ failed", dirPath);
            }
        }
#ifdef DEBUG
        NSLog(@"dbPath:%@", _dbPath);
#endif
    }
    return self;
}

- (void)loadUserSettingsWithUserId:(NSString *)userId {
    if (userId.length == 0 ||
        [_userId isEqualToString:userId]) {
        return;
    }
    
    if (!_dbQueue) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    }
    
    _userId = [userId copy];
    _tableName = [kUserDefaultsTableNamePrefix stringByAppendingString:_userId];
    
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *createTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (key TEXT NOT NULL, type TEXT NOT NULL, value TEXT NOT NULL, PRIMARY KEY(key))", _tableName];
        [db executeUpdate:createTable];
    }];
}

- (BOOL)setObject:(id)dataOrString forKey:(NSString *)key type:(NSString *)type {
    __block BOOL b;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *insert = [NSString stringWithFormat:UPDATE_PROPERTY_TABLE, _tableName];
        b = [db executeUpdate:insert, key, type, dataOrString];
    }];
    return b;
}

- (DataBaseObject *)getObjectForKey:(NSString *)key {
    __block DataBaseObject *obj;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *query = [NSString stringWithFormat:QUERY_PROPERTY_TABLE, _tableName];
        FMResultSet *result = [db executeQuery:query, key];
        obj = [[DataBaseObject alloc] initWithResult:result];
    }];
    return obj;
}

- (nullable id)objectForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    return obj.value;
}

- (BOOL)setObject:(nullable id)value forKey:(NSString *)key {
    if (value == nil) {
        return [self removeObjectForKey:key];
    } else if ([value isKindOfClass:NSString.class]) {
        return [self setObject:value forKey:key type:kUserDefaultsStringType];
    } else if ([value isKindOfClass:NSNumber.class]) {
        NSNumber *number = value;
        NSString *string = [number stringValue];
        return [self setObject:string forKey:key type:kUserDefaultsNumberType];
    } else if ([value isKindOfClass:NSData.class]) {
        return [self setObject:value forKey:key type:kUserDefaultsDataType];
    } else if ([value isKindOfClass:NSDate.class]) {
        return [self setObject:value forKey:key type:kUserDefaultsDateType];
    } else if ([value isKindOfClass:NSArray.class]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
        return [self setObject:data forKey:key type:kUserDefaultsArrayType];
    } else if ([value isKindOfClass:NSDictionary.class]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
        return [self setObject:data forKey:key type:kUserDefaultsDictionaryType];
    }
    return YES;
}

- (BOOL)removeObjectForKey:(NSString *)key {
    __block BOOL b;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *delete = [NSString stringWithFormat:DELETE_PROPERTY_TABLE, _tableName];
        b = [db executeUpdate:delete, key];
    }];
    return b;
}

- (nullable NSString *)stringForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    if ([obj.type isEqualToString:kUserDefaultsStringType]) {
        return obj.value;
    } else {
        return nil;
    }
}

- (nullable NSNumber *)numberForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    if ([obj.type isEqualToString:kUserDefaultsNumberType]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:obj.value];
    } else {
        return nil;
    }
}

- (nullable NSData *)dataForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    if ([obj.type isEqualToString:kUserDefaultsDataType]) {
        return obj.value;
    } else {
        return nil;
    }
}

- (nullable NSDate *)dateForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    if ([obj.type isEqualToString:kUserDefaultsDateType]) {
        return obj.value;
    } else {
        return nil;
    }
}

- (nullable NSArray *)arrayForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    if ([obj.type isEqualToString:kUserDefaultsArrayType]) {
        NSData *data = obj.value;
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([array isKindOfClass:NSArray.class]) {
            return array;
        }
    }
    return nil;
}

- (nullable NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)key {
    DataBaseObject *obj = [self getObjectForKey:key];
    if ([obj.type isEqualToString:kUserDefaultsDictionaryType]) {
        NSData *data = obj.value;
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([dict isKindOfClass:NSDictionary.class]) {
            return dict;
        }
    }
    return nil;
}

- (NSInteger)integerForKey:(NSString *)key {
    return [[self numberForKey:key] integerValue];
}

- (float)floatForKey:(NSString *)key {
    return [[self numberForKey:key] floatValue];
}

- (double)doubleForKey:(NSString *)key {
    return [[self numberForKey:key] doubleValue];
}

- (BOOL)boolForKey:(NSString *)key {
    return [[self numberForKey:key] boolValue];
}

- (BOOL)setInteger:(NSInteger)value forKey:(NSString *)key {
    return [self setObject:@(value) forKey:key];
}

- (BOOL)setFloat:(float)value forKey:(NSString *)key {
    return [self setObject:@(value) forKey:key];
}

- (BOOL)setDouble:(double)value forKey:(NSString *)key {
    return [self setObject:@(value) forKey:key];
}

- (BOOL)setBool:(BOOL)value forKey:(NSString *)key {
    return [self setObject:@(value) forKey:key];
}


@end
