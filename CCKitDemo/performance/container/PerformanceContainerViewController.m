//
//  PerformanceContainerViewController.m
//  CCKitDemo
//
//  Created by rui yuan on 2019/9/5.
//  Copyright © 2019 KudoCC. All rights reserved.
//

#import "PerformanceContainerViewController.h"
#import "CCUtility.h"

static BOOL cclog = YES;

@interface CCPerformanceTestObj : NSObject
@property (nonatomic, copy) NSString *uniqueID;
@end

@implementation CCPerformanceTestObj

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    typeof(self) o = object;
    if (cclog) {
        NSLog(@"%@, %@, compare %@ with %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), o.uniqueID, self.uniqueID);
    }
    return [o.uniqueID isEqualToString:self.uniqueID];
}

- (NSUInteger)hash
{
    if (cclog) {
        NSLog(@"%@, %@, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), self.uniqueID);
    }
    return [self.uniqueID hash];
}

@end

@interface PerformanceContainerViewController ()

@property (nonatomic) NSMutableArray<CCPerformanceTestObj *> *mutableArray;
@property (nonatomic) NSMutableDictionary<NSString *, CCPerformanceTestObj *> *mutableDictionary;
@property (nonatomic) NSMutableSet<CCPerformanceTestObj *> *mutableSet;

@end

@implementation PerformanceContainerViewController

- (void)initView {
    self.mutableArray = [[NSMutableArray alloc] init];
    self.mutableDictionary = [[NSMutableDictionary alloc] init];
    self.mutableSet = [[NSMutableSet alloc] init];
    
    cclog = NO;
    CCPerformanceTestObj *p = nil;
    for (int i = 0; i < 100; ++i) {
        CCPerformanceTestObj *o = [CCPerformanceTestObj new];
        o.uniqueID = [NSString stringWithFormat:@"%d", i];
        if (i == 50) {
            p = o;
        }
        [self.mutableSet addObject:o];
        [self.mutableArray addObject:o];
        [self.mutableDictionary setObject:o forKey:o.uniqueID];
    }
    cclog = YES;
    
    // NSMutableArray removeObject:
    NSLog(@"begin array");
    p = [CCPerformanceTestObj new];
    p.uniqueID = @"50";
    NSTimeInterval dur = [CCUtility calculateTime:^{
        [self.mutableArray removeObject:p];
    }];
    p = [CCPerformanceTestObj new];
    p.uniqueID = @"40";
    dur = [CCUtility calculateTime:^{
        [self.mutableArray removeObject:p];
    }];
    NSLog(@"mutable array remove obj:%@", @(dur));
    
    // NSMutableSet removeObject:
    NSLog(@"begin set remove");
    dur = [CCUtility calculateTime:^{
        [self.mutableSet removeObject:p];
    }];
    NSLog(@"mutable set remove obj:%@", @(dur));
    
    // NSMutableSet addObject:
    NSLog(@"begin set add");
    dur = [CCUtility calculateTime:^{
        CCPerformanceTestObj *newObj = [CCPerformanceTestObj new];
        newObj.uniqueID = @"-1000";
        [self.mutableSet addObject:newObj];
    }];
    NSLog(@"mutable set add obj:%@", @(dur));
    
    // NSMutableDictionary remove
    NSLog(@"begin dictionary remove");
    dur = [CCUtility calculateTime:^{
        [self.mutableDictionary removeObjectForKey:p.uniqueID];
    }];
    NSLog(@"mutable dictionary remove obj:%@", @(dur));
}

- (void)tapClick:(UITapGestureRecognizer *)gr {
    
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    
}

@end
