//
//  KVOPeople.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "KVOPeople.h"

@implementation KVOPeople

- (void)setIdentifier:(NSString *)identifier {
    _identifier = [identifier copy];
}

- (void)setName:(NSString *)name {
    _name = [name copy];
}

@end


@implementation KVOStudent

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;
    if ([theKey isEqualToString:@"grade"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

- (void)setGrade:(NSUInteger)grade {
    if (_grade != grade) {
        [self willChangeValueForKey:@"grade"];
        _grade = grade;
        [self didChangeValueForKey:@"grade"];
    }
}

@end