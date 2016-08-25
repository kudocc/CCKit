//
//  KVOBaseViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "KVOBaseViewController.h"
#import "KVOPeople.h"

@implementation KVOBaseViewController {
    KVOPeople *_people;
}

- (void)dealloc {
    [_people removeObserver:self forKeyPath:@"name"];
    [_people removeObserver:self forKeyPath:@"age"];
}

- (void)initView {
    [super initView];
    
    _people = [[KVOPeople alloc] init];
    [_people addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    [_people addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    
    _people.name = @"KudoCC";
    _people.age = 12;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _people) {
        if ([keyPath isEqualToString:@"name"]) {
            NSLog(@"name changed to %@", change[NSKeyValueChangeNewKey]);
        } else if ([keyPath isEqualToString:@"age"]) {
            NSLog(@"age changed to %@", change[NSKeyValueChangeNewKey]);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
