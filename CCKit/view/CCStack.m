//
//  CCStack.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCStack.h"

@implementation CCStack {
    NSMutableArray *_mutableArray;
}

- (id)init {
    self = [super init];
    if (self) {
        _mutableArray = [NSMutableArray array];
    }
    return self;
}

- (id)top {
    return [_mutableArray lastObject];
}

- (void)push:(id)obj {
    [_mutableArray addObject:obj];
}

- (id)pop {
    id obj = [_mutableArray lastObject];
    if (obj) {
        [_mutableArray removeObject:obj];
    }
    return obj;
}

- (void)popAll {
    [_mutableArray removeAllObjects];
}

- (BOOL)isEmpty {
    return [_mutableArray count] == 0;
}

@end
