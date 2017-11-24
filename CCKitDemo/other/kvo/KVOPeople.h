//
//  KVOPeople.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVOPeople : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSUInteger age;

@end


@interface KVOStudent : KVOPeople

@property (nonatomic) NSUInteger grade;

@property (nonatomic, readonly) NSString *valueNotBackedByVariable;

- (void)triggerTestKVO;

@end
