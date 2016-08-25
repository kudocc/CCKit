//
//  KVOSubViewController.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "KVOSubViewController.h"
#import "KVOPeople.h"

@implementation KVOSubViewController {
    KVOStudent *_student;
}

- (void)dealloc {
    [_student removeObserver:self forKeyPath:@"grade"];
    [_student removeObserver:self forKeyPath:@"age"];
}

- (void)initView {
    [super initView];
    
    _student = [[KVOStudent alloc] init];
    [_student addObserver:self forKeyPath:@"grade" options:NSKeyValueObservingOptionNew context:nil];
    [_student addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    
    _student.age = 10;
    _student.grade = 2;
    _student.grade = 2;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _student) {
        if ([keyPath isEqualToString:@"grade"]) {
            NSLog(@"grade changed to %@", change[NSKeyValueChangeNewKey]);
        } else if ([keyPath isEqualToString:@"age"]) {
            NSLog(@"age changed to %@", change[NSKeyValueChangeNewKey]);
        }
    } else {
        // we must call super, or KVOBaseViewController's observeValueForKeyPath:... won't get called.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
